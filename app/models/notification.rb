class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"
  belongs_to :notifiable, polymorphic: true

  ACTIONS = %w[reply reply_to_reply mention accepted_answer subscription moderation].freeze

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
  end

  def message_preview
    case action
    when "reply"
      "#{actor.display_title} replied to your discussion"
    when "reply_to_reply"
      "#{actor.display_title} replied to your comment"
    when "mention"
      "#{actor.display_title} mentioned you in a discussion"
    when "accepted_answer"
      "#{actor.display_title} marked your reply as the accepted answer"
    when "subscription"
      "New activity on a discussion you are following"
    when "moderation"
      "A moderation update was applied to your content"
    else
      "You have a new update from #{actor.display_title}"
    end
  end
end
