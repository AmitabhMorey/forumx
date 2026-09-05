module Replies
  class CreateService
    Result = Struct.new(:success, :reply, :errors, keyword_init: true) do
      def success?
        success
      end
    end

    def self.call(user:, discussion:, params:)
      new(user: user, discussion: discussion, params: params).call
    end

    def initialize(user:, discussion:, params:)
      @user = user
      @discussion = discussion
      @params = params
    end

    def call
      if @discussion.locked? || @discussion.archived?
        return Result.new(success: false, reply: nil, errors: ["Discussion is locked and cannot receive new replies."])
      end

      reply = @discussion.replies.build(@params.merge(user: @user))

      ActiveRecord::Base.transaction do
        if reply.save
          # Award reputation (+2 for reply)
          @user.increment!(:reputation, 2)

          # 1. Notify discussion author if not self
          if @discussion.user_id != @user.id
            Notification.find_or_create_by(
              recipient: @discussion.user,
              actor: @user,
              notifiable: reply,
              action: "reply"
            )
          end

          # 2. If nested reply, notify parent reply author if not self and not discussion author
          if reply.parent_reply.present? && reply.parent_reply.user_id != @user.id && reply.parent_reply.user_id != @discussion.user_id
            Notification.find_or_create_by(
              recipient: reply.parent_reply.user,
              actor: @user,
              notifiable: reply,
              action: "reply_to_reply"
            )
          end

          # 3. Notify discussion subscribers
          excluded_ids = [@user.id, @discussion.user_id]
          excluded_ids << reply.parent_reply.user_id if reply.parent_reply.present?

          @discussion.subscribers.where.not(id: excluded_ids).find_each do |subscriber|
            Notification.create(
              recipient: subscriber,
              actor: @user,
              notifiable: reply,
              action: "subscription"
            )
          rescue ActiveRecord::RecordNotUnique
            # Ignore
          end

          # Parse @mentions
          Mentions::MentionParser.parse_and_notify!(reply, @user)

          # Check badges
          Badges::BadgeAwarder.check_and_award!(@user)

          Result.new(success: true, reply: reply, errors: nil)
        else
          Result.new(success: false, reply: reply, errors: reply.errors)
        end
      end
    rescue StandardError => e
      Result.new(success: false, reply: reply, errors: [e.message])
    end
  end
end
