class ModerationLog < ApplicationRecord
  belongs_to :moderator, class_name: "User"
  belongs_to :target, polymorphic: true, optional: true

  ACTIONS = %w[
    remove_discussion
    restore_discussion
    remove_reply
    restore_reply
    lock_discussion
    unlock_discussion
    pin_discussion
    unpin_discussion
    suspend_user
    unsuspend_user
  ].freeze

  validates :action, presence: true, inclusion: { in: ACTIONS }
  validates :target_type, presence: true
  validates :target_id, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def action_humanized
    action.tr("_", " ").titleize
  end
end
