class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge

  validates :user_id, uniqueness: { scope: :badge_id }

  before_create :set_awarded_at

  private

  def set_awarded_at
    self.awarded_at ||= Time.current
  end
end
