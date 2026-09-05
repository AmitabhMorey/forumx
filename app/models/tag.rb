class Tag < ApplicationRecord
  has_many :discussion_tags, dependent: :destroy
  has_many :discussions, through: :discussion_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }

  before_validation :generate_slug

  scope :popular, -> { order(discussions_count: :desc) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.to_s.parameterize if slug.blank? && name.present?
  end
end
