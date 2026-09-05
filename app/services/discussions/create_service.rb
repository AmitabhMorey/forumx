module Discussions
  class CreateService
    Result = Struct.new(:success, :discussion, :errors, keyword_init: true) do
      def success?
        success
      end
    end

    def self.call(user:, params:)
      new(user: user, params: params).call
    end

    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      discussion = @user.discussions.build(@params)

      ActiveRecord::Base.transaction do
        if discussion.save
          # Automatically subscribe author to receive replies
          @user.subscriptions.find_or_create_by!(discussion: discussion)

          # Award reputation (+5 for starting a discussion)
          @user.increment!(:reputation, 5)

          # Parse @mentions
          Mentions::MentionParser.parse_and_notify!(discussion, @user)

          # Evaluate badges
          Badges::BadgeAwarder.check_and_award!(@user)

          Result.new(success: true, discussion: discussion, errors: nil)
        else
          Result.new(success: false, discussion: discussion, errors: discussion.errors)
        end
      end
    rescue StandardError => e
      Result.new(success: false, discussion: discussion, errors: [e.message])
    end
  end
end
