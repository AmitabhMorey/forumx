class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers
  allow_browser versions: :modern, unless: -> { Rails.env.test? }
  stale_when_importmap_changes

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_user_suspension
  before_action :set_unread_notifications_count

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :display_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:display_name, :bio, :website, :location, :avatar_url])
  end

  def check_user_suspension
    return unless user_signed_in? && current_user.suspended?

    sign_out current_user
    redirect_to root_path, alert: "Your account has been suspended by a moderator."
  end

  def set_unread_notifications_count
    @unread_notifications_count = current_user&.received_notifications&.unread&.count || 0 if user_signed_in?
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to(root_path)
  end
end
