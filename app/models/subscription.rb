class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :discussion

  validates :discussion_id, uniqueness: { scope: :user_id, message: "is already being followed" }
end
