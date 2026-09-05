module Admin
  class UsersController < BaseController
    before_action :ensure_admin!, only: [:update_role]
    before_action :set_user, only: [:show, :suspend, :unsuspend, :update_role]

    def index
      @users = User.all

      @users = @users.where(role: params[:role]) if params[:role].present?

      if params[:status] == "suspended"
        @users = @users.suspended
      elsif params[:status] == "active"
        @users = @users.active
      end

      if params[:q].present?
        q = "%#{ActiveRecord::Base.sanitize_sql_like(params.expect(:q).strip)}%"
        @users = @users.where("username ILIKE ? OR email ILIKE ? OR display_name ILIKE ?", q, q, q)
      end

      @users = @users.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
      @discussions = @user.discussions.latest.limit(10)
      @replies = @user.replies.includes(:discussion).order(created_at: :desc).limit(10)
      @moderation_logs = ModerationLog.where(target_type: "User", target_id: @user.id).recent
    end

    def suspend
      authorize @user, :suspend?
      reason = params[:reason].presence || "Suspended by #{current_user.username}"
      Moderation::ModerationService.new(moderator: current_user).suspend_user(@user, reason: reason)
      redirect_back_or_to(admin_user_path(@user), notice: "User @#{@user.username} has been suspended.")
    end

    def unsuspend
      authorize @user, :unsuspend?
      Moderation::ModerationService.new(moderator: current_user).unsuspend_user(@user)
      redirect_back_or_to(admin_user_path(@user), notice: "Suspension lifted for @#{@user.username}.")
    end

    def update_role
      new_role = params[:role]
      if User.roles.keys.include?(new_role)
        @user.update!(role: new_role)
        ModerationLog.create!(
          moderator: current_user,
          action: "update_role",
          target_type: "User",
          target_id: @user.id,
          reason: "Role changed to #{new_role}",
          metadata: { new_role: new_role }
        )
        redirect_back_or_to(admin_user_path(@user), notice: "Role updated to #{new_role.capitalize}.")
      else
        redirect_back_or_to(admin_user_path(@user), alert: "Invalid role specified.")
      end
    end

    private

    def set_user
      @user = User.find_by(username: params[:id]) || User.find_by(id: params[:id])
      raise ActiveRecord::RecordNotFound, "Couldn't find User with id #{params[:id]}" unless @user
    end
  end
end
