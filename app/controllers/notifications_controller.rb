class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.received_notifications
                                 .includes(:actor, :notifiable)
                                 .recent
                                 .page(params[:page])
                                 .per(20)

    # If requested unread only
    @notifications = @notifications.unread if params[:filter] == "unread"
  end

  def update
    @notification = current_user.received_notifications.find(params.expect(:id))
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back_or_to(notifications_path) }
    end
  end

  def mark_all_read
    current_user.received_notifications.unread.update_all(read_at: Time.current)

    respond_to do |format|
      format.turbo_stream { redirect_to notifications_path, notice: "All notifications marked as read." }
      format.html { redirect_to notifications_path, notice: "All notifications marked as read." }
    end
  end
end
