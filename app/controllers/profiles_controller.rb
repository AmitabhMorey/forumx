class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to user_profile_path(current_user)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to user_profile_path(@user), notice: "Profile updated successfully!"
    else
      flash.now[:alert] = "Failed to update profile."
      render :edit, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.expect(user: [:display_name, :bio, :website, :location, :avatar_url])
  end
end
