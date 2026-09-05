require 'rails_helper'

RSpec.describe "Admin Area", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:standard_user) { create(:user) }

  describe "GET /admin" do
    it "allows access for admins and moderators" do
      sign_in admin_user
      get admin_root_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Moderation & Platform Overview")
    end

    it "blocks access for normal users" do
      sign_in standard_user
      get admin_root_path
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include("Access denied")
    end
  end

  describe "POST /admin/users/:id/suspend" do
    let(:target_user) { create(:user) }

    it "suspends user and logs the moderation action" do
      sign_in admin_user
      post suspend_admin_user_path(target_user), params: { reason: "Spamming links" }
      expect(target_user.reload.suspended?).to be true
      expect(ModerationLog.exists?(target_type: "User", target_id: target_user.id)).to be true
    end
  end
end
