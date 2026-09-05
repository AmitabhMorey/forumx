module Discussions
  class AcceptAnswerService
    Result = Struct.new(:success, :accepted, :discussion, :reply, :error, keyword_init: true) do
      def success?
        success
      end
    end

    def self.call(user:, discussion:, reply:)
      new(user: user, discussion: discussion, reply: reply).call
    end

    def initialize(user:, discussion:, reply:)
      @user = user
      @discussion = discussion
      @reply = reply
    end

    def call
      return Result.new(success: false, error: "Only the discussion author can accept an answer") unless @discussion.user_id == @user.id
      return Result.new(success: false, error: "Reply does not belong to this discussion") unless @reply.discussion_id == @discussion.id

      reply_author = @reply.user

      ActiveRecord::Base.transaction do
        if @discussion.accepted_reply_id == @reply.id
          # Toggle off: unaccept answer
          @discussion.unaccept_reply!
          reply_author.decrement!(:reputation, 10)

          Result.new(success: true, accepted: false, discussion: @discussion, reply: @reply)
        else
          # If another reply was accepted, revert its author's 10 rep
          if @discussion.accepted_reply.present?
            previous_author = @discussion.accepted_reply.user
            previous_author.decrement!(:reputation, 10)
          end

          @discussion.accept_reply!(@reply)
          reply_author.increment!(:reputation, 10)

          # Notify reply author if not self
          if reply_author.id != @user.id
            Notification.find_or_create_by(
              recipient: reply_author,
              actor: @user,
              notifiable: @reply,
              action: "accepted_answer"
            )
          end

          # Award Problem Solver badge
          Badges::BadgeAwarder.check_and_award!(reply_author)

          Result.new(success: true, accepted: true, discussion: @discussion, reply: @reply)
        end
      end
    rescue StandardError => e
      Result.new(success: false, error: e.message)
    end
  end
end
