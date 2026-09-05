module Badges
  class BadgeAwarder
    def self.check_and_award!(user)
      return unless user.is_a?(User)

      # 1. First Post: 1+ discussion or 1+ reply
      if (user.discussions_count + user.replies_count) >= 1
        award!(user, "first-post", "First Post", "Contributed your first discussion or reply", "sparkles", "bronze")
      end

      # 2. Discussion Starter: 5+ discussions
      if user.discussions_count >= 5
        award!(user, "discussion-starter", "Discussion Starter", "Created 5 or more discussions", "chat-bubble-left-right", "silver")
      end

      # 3. Helpful Member: 10+ replies
      if user.replies_count >= 10
        award!(user, "helpful-member", "Helpful Member", "Contributed 10 or more helpful replies", "heart", "silver")
      end

      # 4. Problem Solver: accepted answer
      if user.replies.exists?(is_accepted: true)
        award!(user, "problem-solver", "Problem Solver", "Authored an accepted solution to a community question", "check-badge", "gold")
      end

      # 5. Top Contributor: 50+ reputation
      return unless user.reputation >= 50

      award!(user, "top-contributor", "Top Contributor", "Reached over 50 reputation score", "trophy", "gold")
    end

    def self.award!(user, slug, name, description, icon, badge_type)
      badge = Badge.find_or_create_by!(slug: slug) do |b|
        b.name = name
        b.description = description
        b.icon = icon
        b.badge_type = badge_type
      end

      return if user.user_badges.exists?(badge_id: badge.id)

      user.user_badges.create!(badge: badge, awarded_at: Time.current)
    rescue ActiveRecord::RecordNotUnique
      # Concurrency safeguard
    end
  end
end
