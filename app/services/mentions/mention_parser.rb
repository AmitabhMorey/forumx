module Mentions
  class MentionParser
    # Matches @username where username is 3-30 alphanumeric characters and underscores
    MENTION_REGEX = /(?:^|\s)@([a-zA-Z0-9_]{3,30})/

    def self.parse_and_notify!(mentionable, author)
      return if mentionable.nil? || author.nil?

      text = mentionable.body.to_s
      usernames = text.scan(MENTION_REGEX).flatten.map(&:downcase).uniq

      return if usernames.empty?

      # Find matching active users, excluding author
      users = User.active.where(username: usernames).where.not(id: author.id)

      users.each do |user|
        mentionable.mentions.find_or_create_by(user: user)

        # Notify mentioned user
        Notification.find_or_create_by(
          recipient: user,
          actor: author,
          notifiable: mentionable,
          action: "mention"
        )
      rescue ActiveRecord::RecordNotUnique
        # Skip if already exists
      end
    end
  end
end
