class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :voteable, polymorphic: true

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: [:voteable_type, :voteable_id], message: "has already voted" }
  validate :prevent_self_voting

  scope :upvotes, -> { where(value: 1) }
  scope :downvotes, -> { where(value: -1) }

  private

  def prevent_self_voting
    return unless voteable.present? && user.present?

    return unless voteable.user_id == user_id

    errors.add(:base, "You cannot vote on your own content")
  end
end
