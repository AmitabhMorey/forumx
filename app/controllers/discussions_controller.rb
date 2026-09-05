class DiscussionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_discussion, only: [:show, :edit, :update, :destroy, :bookmark, :subscribe, :lock, :unlock, :pin, :unpin]

  def index
    @sort = params[:sort].presence || "trending"
    scope = Discussion.includes(:user, :category, :tags)

    if params[:category].present?
      @category = Category.find_by(slug: params[:category])
      scope = scope.where(category: @category) if @category
    end

    if params[:tag].present?
      @tag = Tag.find_by(slug: params[:tag])
      scope = scope.joins(:tags).where(tags: { id: @tag.id }) if @tag
    end

    scope = case @sort
            when "latest"
              scope.latest
            when "votes"
              scope.most_votes
            when "replies"
              scope.most_replies
            when "views"
              scope.most_viewed
            else
              scope.trending
            end

    @discussions = scope.page(params[:page]).per(15)
    @popular_tags = Tag.popular.limit(10)
    @categories = Category.ordered
  end

  def show
    @discussion.increment_views!

    # Eager load root replies with user and nested replies
    @replies = @discussion.replies
                          .root_replies
                          .includes(:user, :votes, child_replies: [:user, :votes, { child_replies: [:user, :votes] }])
                          .chronological

    @new_reply = @discussion.replies.build
    @user_voted = current_user ? current_user.vote_for(@discussion)&.value : 0
    @is_bookmarked = current_user ? current_user.bookmarked?(@discussion) : false
    @is_subscribed = current_user ? current_user.subscribed?(@discussion) : false
    @related_discussions = Discussion.where(category_id: @discussion.category_id)
                                     .where.not(id: @discussion.id)
                                     .latest
                                     .limit(5)
  end

  def new
    @discussion = current_user.discussions.build(category_id: params[:category_id])
    authorize @discussion
  end

  def edit
    authorize @discussion
  end

  def create
    @discussion = current_user.discussions.build
    authorize @discussion

    result = Discussions::CreateService.call(
      user: current_user,
      params: discussion_params
    )

    if result.success?
      redirect_to discussion_path(result.discussion), notice: "Discussion created successfully!"
    else
      @discussion = result.discussion
      flash.now[:alert] = "Please fix the errors below."
      render :new, status: :unprocessable_content
    end
  end

  def update
    authorize @discussion

    if @discussion.update(discussion_params)
      redirect_to discussion_path(@discussion), notice: "Discussion updated successfully."
    else
      flash.now[:alert] = "Failed to update discussion."
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @discussion
    @discussion.destroy!
    redirect_to root_path, notice: "Discussion was deleted."
  end

  def bookmark
    bookmark = current_user.bookmarks.find_by(discussion: @discussion)

    if bookmark
      bookmark.destroy
      @is_bookmarked = false
    else
      current_user.bookmarks.create!(discussion: @discussion)
      @is_bookmarked = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to(discussion_path(@discussion)) }
    end
  end

  def subscribe
    subscription = current_user.subscriptions.find_by(discussion: @discussion)

    if subscription
      subscription.destroy
      @is_subscribed = false
    else
      current_user.subscriptions.create!(discussion: @discussion)
      @is_subscribed = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to(discussion_path(@discussion)) }
    end
  end

  def lock
    authorize @discussion, :lock?
    Moderation::ModerationService.new(moderator: current_user).lock_discussion(@discussion)
    redirect_back_or_to(discussion_path(@discussion), notice: "Discussion locked.")
  end

  def unlock
    authorize @discussion, :unlock?
    Moderation::ModerationService.new(moderator: current_user).unlock_discussion(@discussion)
    redirect_back_or_to(discussion_path(@discussion), notice: "Discussion unlocked.")
  end

  def pin
    authorize @discussion, :pin?
    Moderation::ModerationService.new(moderator: current_user).pin_discussion(@discussion)
    redirect_back_or_to(discussion_path(@discussion), notice: "Discussion pinned.")
  end

  def unpin
    authorize @discussion, :unpin?
    Moderation::ModerationService.new(moderator: current_user).unpin_discussion(@discussion)
    redirect_back_or_to(discussion_path(@discussion), notice: "Discussion unpinned.")
  end

  private

  def set_discussion
    @discussion = Discussion.find_by!(slug: params.expect(:id))
  end

  def discussion_params
    params.expect(discussion: [:title, :category_id, :body, :tag_names])
  end
end
