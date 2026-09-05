class Discussion < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :category, counter_cache: true
  belongs_to :accepted_reply, class_name: "Reply", optional: true

  has_many :replies, dependent: :destroy
  has_many :discussion_tags, dependent: :destroy
  has_many :tags, through: :discussion_tags
  has_many :votes, as: :voteable, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by_users, through: :bookmarks, source: :user
  has_many :subscriptions, dependent: :destroy
  has_many :subscribers, through: :subscriptions, source: :user
  has_many :mentions, as: :mentionable, dependent: :destroy
  has_many :reports, as: :reportable, dependent: :destroy

  enum :status, { open: 0, locked: 1, resolved: 2, archived: 3 }

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :body, presence: true, length: { minimum: 10 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  before_validation :generate_unique_slug

  # Scopes for sorting
  scope :pinned_first, -> { order(pinned: :desc) }
  scope :latest, -> { order(created_at: :desc) }
  scope :most_votes, -> { order(vote_score: :desc, created_at: :desc) }
  scope :most_replies, -> { order(reply_count: :desc, created_at: :desc) }
  scope :most_viewed, -> { order(view_count: :desc, created_at: :desc) }
  scope :recently_updated, -> { order(updated_at: :desc) }
  scope :trending, lambda {
    # Hot ranking based on votes, replies, and views
    order(Arel.sql("(vote_score * 3 + reply_count * 2 + view_count * 0.1) DESC, created_at DESC"))
  }

  def to_param
    slug
  end

  def increment_views!
    increment!(:view_count)
  end

  def tag_names
    tags.pluck(:name).join(", ")
  end

  def tag_names=(names_str)
    tag_names_array = names_str.to_s.split(",").map(&:strip).compact_blank.uniq.take(5)
    self.tags = tag_names_array.map do |name|
      Tag.find_or_create_by!(name: name) do |t|
        t.slug = name.parameterize
      end
    end
  end

  def accept_reply!(reply)
    return false unless reply.discussion_id == id

    transaction do
      # If there was a previously accepted reply, unset it
      accepted_reply.update!(is_accepted: false) if accepted_reply.present? && accepted_reply != reply

      reply.update!(is_accepted: true)
      update!(accepted_reply: reply, status: :resolved)
    end
  end

  def unaccept_reply!
    return false if accepted_reply.blank?

    transaction do
      accepted_reply.update!(is_accepted: false)
      update!(accepted_reply: nil, status: :open)
    end
  end

  private

  def generate_unique_slug
    return if slug.present? && !title_changed?

    base = title.to_s.parameterize
    base = "discussion" if base.blank?

    candidate = base
    counter = 1
    while Discussion.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{counter}"
      counter += 1
    end
    self.slug = candidate
  end
end
