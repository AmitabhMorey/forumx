class Report < ApplicationRecord
  belongs_to :reporter, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true
  belongs_to :reportable, polymorphic: true

  REASONS = [
    "Spam",
    "Harassment",
    "Hate",
    "Off-topic",
    "Copyright",
    "Malicious Content",
    "Other"
  ].freeze

  enum :status, { pending: 0, resolved: 1, dismissed: 2 }

  validates :reason, presence: true, inclusion: { in: REASONS }
  validates :description, length: { maximum: 1000 }
  validates :reporter_id, uniqueness: { scope: [:reportable_type, :reportable_id], message: "You have already reported this item" }

  scope :pending, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }

  def resolve!(moderator)
    update!(status: :resolved, reviewed_by: moderator, reviewed_at: Time.current)
  end

  def dismiss!(moderator)
    update!(status: :dismissed, reviewed_by: moderator, reviewed_at: Time.current)
  end
end
