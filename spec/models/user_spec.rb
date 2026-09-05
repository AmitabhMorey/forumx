require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:username) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
    it { is_expected.to allow_value("valid_user123").for(:username) }
    it { is_expected.not_to allow_value("invalid user!").for(:username) }
    it { is_expected.not_to allow_value("ab").for(:username) }
  end

  describe "roles" do
    it "defaults to standard user role" do
      user = create(:user)
      expect(user.role).to eq("user")
      expect(user.user?).to be true
      expect(user.can_moderate?).to be false
    end

    it "recognizes moderator permissions" do
      moderator = create(:user, :moderator)
      expect(moderator.can_moderate?).to be true
    end

    it "recognizes admin permissions" do
      admin = create(:user, :admin)
      expect(admin.admin?).to be true
      expect(admin.can_moderate?).to be true
    end
  end

  describe "suspension" do
    it "checks whether user is suspended" do
      user = create(:user)
      expect(user.suspended?).to be false

      user.suspend!(reason: "Violation")
      expect(user.suspended?).to be true
      expect(user.active_for_authentication?).to be false

      user.unsuspend!
      expect(user.suspended?).to be false
      expect(user.active_for_authentication?).to be true
    end
  end
end
