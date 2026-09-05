class Reply < ApplicationRecord
  belongs_to :discussion, counter_cache: :reply_count
  belongs_to :user, counter_cache: :replies_count
  belongs_to :parent_reply, class_name: "Reply", optional: true

  has_many :child_replies, class_name: "Reply", foreign_key: :parent_reply_id, dependent: :destroy
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :mentions, as: :mentionable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  enum :status, { visible: 0, removed: 1 }

  validates :body, presence: true, length: { minimum: 2 }

  scope :root_replies, -> { where(parent_reply_id: nil) }
  scope :visible_only, -> { where(status: :visible) }
  scope :chronological, -> { order(created_at: :asc) }

  def depth
    level = 0
    current = parent_reply
    while current.present?
      level += 1
      current = current.parent_reply
      break if level > 10 # guard against cyclic loops
    end
    level
  end

  def accepted?
    is_accepted?
  end
end
