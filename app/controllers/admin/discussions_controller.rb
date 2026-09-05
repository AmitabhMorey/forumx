module Admin
  class DiscussionsController < BaseController
    before_action :set_discussion, only: [:show, :destroy, :lock, :unlock, :pin, :unpin, :restore]

    def index
      @discussions = Discussion.includes(:user, :category)

      @discussions = @discussions.where(status: params[:status]) if params[:status].present?

      @discussions = @discussions.where(pinned: true) if params[:pinned] == "true"

      if params[:q].present?
        q = "%#{ActiveRecord::Base.sanitize_sql_like(params.expect(:q).strip)}%"
        @discussions = @discussions.where("title ILIKE ?", q)
      end

      @discussions = @discussions.latest.page(params[:page]).per(20)
    end

    def show; end

    def destroy
      Moderation::ModerationService.new(moderator: current_user).remove_discussion(@discussion,
                                                                                   reason: params[:reason].presence || "Removed via Admin")
      redirect_back_or_to(admin_discussions_path, notice: "Discussion archived.")
    end

    def restore
      Moderation::ModerationService.new(moderator: current_user).restore_discussion(@discussion)
      redirect_back_or_to(admin_discussions_path, notice: "Discussion restored.")
    end

    def lock
      Moderation::ModerationService.new(moderator: current_user).lock_discussion(@discussion)
      redirect_back_or_to(admin_discussions_path, notice: "Discussion locked.")
    end

    def unlock
      Moderation::ModerationService.new(moderator: current_user).unlock_discussion(@discussion)
      redirect_back_or_to(admin_discussions_path, notice: "Discussion unlocked.")
    end

    def pin
      Moderation::ModerationService.new(moderator: current_user).pin_discussion(@discussion)
      redirect_back_or_to(admin_discussions_path, notice: "Discussion pinned.")
    end

    def unpin
      Moderation::ModerationService.new(moderator: current_user).unpin_discussion(@discussion)
      redirect_back_or_to(admin_discussions_path, notice: "Discussion unpinned.")
    end

    private

    def set_discussion
      @discussion = Discussion.find_by!(slug: params.expect(:id))
    end
  end
end
