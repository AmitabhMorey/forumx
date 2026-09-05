class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { user: 0, moderator: 1, admin: 2 }

  # Associations
  has_many :discussions, dependent: :destroy
  has_many :replies, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_discussions, through: :bookmarks, source: :discussion
  has_many :subscriptions, dependent: :destroy
  has_many :subscribed_discussions, through: :subscriptions, source: :discussion
  has_many :received_notifications, class_name: "Notification", foreign_key: :recipient_id, dependent: :destroy
  has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :destroy
  has_many :reports, foreign_key: :reporter_id, dependent: :destroy
  has_many :reviewed_reports, class_name: "Report", foreign_key: :reviewed_by_id, dependent: :nullify
  has_many :moderation_logs, foreign_key: :moderator_id, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  has_many :mentions, dependent: :destroy

  # Validations
  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 },
                       format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" }
  validates :role, presence: true
  validates :reputation, numericality: { only_integer: true }

  before_validation :normalize_username

  # Scopes
  scope :active, -> { where(suspended_at: nil) }
  scope :suspended, -> { where.not(suspended_at: nil) }
  scope :top_contributors, -> { order(reputation: :desc).limit(10) }

  # Friendly URL routing
  def to_param
    username
  end

  def suspended?
    suspended_at.present?
  end

  def suspend!(reason: nil)
    update!(suspended_at: Time.current)
  end

  def unsuspend!
    update!(suspended_at: nil)
  end

  def active_for_authentication?
    super && !suspended?
  end

  def inactive_message
    suspended? ? :suspended : super
  end

  def display_title
    display_name.presence || username
  end

  def avatar_display_url
    if avatar_url.present?
      avatar_url
    else
      hash = Digest::MD5.hexdigest(email.downcase.strip)
      "https://www.gravatar.com/avatar/#{hash}?d=identicon&s=128"
    end
  end

  def bookmarked?(discussion)
    bookmarks.exists?(discussion_id: discussion.id)
  end

  def subscribed?(discussion)
    subscriptions.exists?(discussion_id: discussion.id)
  end

  def vote_for(voteable)
    votes.find_by(voteable: voteable)
  end

  def can_moderate?
    moderator? || admin?
  end

  private

  def normalize_username
    self.username = username.to_s.strip.downcase if username.present?
  end
end
