module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_moderator_or_admin!
    layout "admin"

    private

    def ensure_moderator_or_admin!
      return if current_user&.can_moderate?

      flash[:alert] = "Access denied. Moderator privileges required."
      redirect_to root_path
    end

    def ensure_admin!
      return if current_user&.admin?

      flash[:alert] = "Access denied. Administrator privileges required."
      redirect_to admin_root_path
    end
  end
end
