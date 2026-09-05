module Admin
  class RepliesController < BaseController
    before_action :set_reply, only: [:destroy, :restore]

    def index
      @replies = Reply.includes(:user, :discussion)

      @replies = @replies.where(status: params[:status]) if params[:status].present?

      if params[:q].present?
        q = "%#{ActiveRecord::Base.sanitize_sql_like(params.expect(:q).strip)}%"
        @replies = @replies.where("body ILIKE ?", q)
      end

      @replies = @replies.order(created_at: :desc).page(params[:page]).per(20)
    end

    def destroy
      Moderation::ModerationService.new(moderator: current_user).remove_reply(@reply,
                                                                              reason: params[:reason].presence || "Removed via Admin")
      redirect_back_or_to(admin_replies_path, notice: "Reply hidden.")
    end

    def restore
      Moderation::ModerationService.new(moderator: current_user).restore_reply(@reply)
      redirect_back_or_to(admin_replies_path, notice: "Reply restored.")
    end

    private

    def set_reply
      @reply = Reply.find(params.expect(:id))
    end
  end
end
