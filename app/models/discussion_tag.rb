class DiscussionTag < ApplicationRecord
  belongs_to :discussion
  belongs_to :tag, counter_cache: :discussions_count

  validates :tag_id, uniqueness: { scope: :discussion_id }
end
