module Users
  class RegistrationsController < Devise::RegistrationsController
    protected

    def after_sign_up_path_for(_resource)
      root_path
    end

    def after_update_path_for(resource)
      user_profile_path(resource)
    end
  end
end
