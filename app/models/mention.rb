class Mention < ApplicationRecord
  belongs_to :user
  belongs_to :mentionable, polymorphic: true

  validates :user_id, uniqueness: { scope: [:mentionable_type, :mentionable_id], message: "has already been mentioned" }
end
