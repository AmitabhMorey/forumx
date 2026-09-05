class UsersController < ApplicationController
  def show
    @user = User.find_by!(username: params.expect(:username).downcase)
    @tab = params[:tab].presence || "overview"

    case @tab
    when "discussions"
      @discussions = @user.discussions.includes(:category, :tags).latest.page(params[:page]).per(10)
    when "replies"
      @replies = @user.replies.includes(:discussion).order(created_at: :desc).page(params[:page]).per(10)
    when "badges"
      @user_badges = @user.user_badges.includes(:badge).order(awarded_at: :desc)
    when "bookmarks"
      @bookmarks = if current_user == @user
                     @user.bookmarked_discussions.includes(:category, :tags).latest.page(params[:page]).per(10)
                   else
                     Discussion.none.page(params[:page])
                   end
    else
      @recent_discussions = @user.discussions.includes(:category).latest.limit(5)
      @recent_replies = @user.replies.includes(:discussion).order(created_at: :desc).limit(5)
      @badges = @user.badges.limit(6)
    end
  end
end
