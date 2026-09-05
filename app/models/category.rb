class Category < ApplicationRecord
  has_many :discussions, dependent: :restrict_with_error

  validates :name, presence: true, length: { maximum: 100 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false },
                   format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug

  scope :ordered, -> { order(position: :asc, name: :asc) }

  def to_param
    slug
  end

  def latest_discussion
    discussions.order(created_at: :desc).first
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
