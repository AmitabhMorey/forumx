class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :discussion

  validates :discussion_id, uniqueness: { scope: :user_id, message: "has already been bookmarked" }
end
