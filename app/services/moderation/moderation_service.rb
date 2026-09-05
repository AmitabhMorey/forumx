module Moderation
  class ModerationService
    def initialize(moderator:)
      @moderator = moderator
    end

    def lock_discussion(discussion, reason: "Locked by moderator")
      return false unless can_moderate?

      discussion.update!(status: :locked)
      log_action("lock_discussion", discussion, reason)
      notify_owner(discussion.user, discussion, "Your discussion has been locked by a moderator: #{reason}")
      true
    end

    def unlock_discussion(discussion, reason: "Unlocked by moderator")
      return false unless can_moderate?

      discussion.update!(status: :open)
      log_action("unlock_discussion", discussion, reason)
      true
    end

    def pin_discussion(discussion, reason: "Pinned by moderator")
      return false unless can_moderate?

      discussion.update!(pinned: true)
      log_action("pin_discussion", discussion, reason)
      true
    end

    def unpin_discussion(discussion, reason: "Unpinned by moderator")
      return false unless can_moderate?

      discussion.update!(pinned: false)
      log_action("unpin_discussion", discussion, reason)
      true
    end

    def remove_discussion(discussion, reason: "Violates community guidelines")
      return false unless can_moderate?

      discussion.update!(status: :archived)
      log_action("remove_discussion", discussion, reason)
      notify_owner(discussion.user, discussion, "Your discussion was archived by a moderator: #{reason}")
      true
    end

    def restore_discussion(discussion, reason: "Restored by moderator")
      return false unless can_moderate?

      discussion.update!(status: :open)
      log_action("restore_discussion", discussion, reason)
      true
    end

    def remove_reply(reply, reason: "Violates community guidelines")
      return false unless can_moderate?

      reply.update!(status: :removed)
      log_action("remove_reply", reply, reason)
      notify_owner(reply.user, reply, "Your comment was hidden by a moderator: #{reason}")
      true
    end

    def restore_reply(reply, reason: "Restored by moderator")
      return false unless can_moderate?

      reply.update!(status: :visible)
      log_action("restore_reply", reply, reason)
      true
    end

    def suspend_user(user, reason: "Repeated community guideline violations")
      return false unless can_moderate?

      user.suspend!(reason: reason)
      log_action("suspend_user", user, reason)
      true
    end

    def unsuspend_user(user, reason: "Suspension lifted by moderator")
      return false unless can_moderate?

      user.unsuspend!
      log_action("unsuspend_user", user, reason)
      true
    end

    private

    def can_moderate?
      @moderator.present? && @moderator.can_moderate?
    end

    def log_action(action, target, reason)
      ModerationLog.create!(
        moderator: @moderator,
        action: action,
        target_type: target.class.name,
        target_id: target.id,
        reason: reason,
        metadata: {
          target_repr: (target.respond_to?(:title) ? target.title : target.try(:display_title) || target.id).to_s
        }
      )
    end

    def notify_owner(recipient, notifiable, _message)
      return if recipient.id == @moderator.id

      Notification.create(
        recipient: recipient,
        actor: @moderator,
        notifiable: notifiable,
        action: "moderation"
      )
    rescue ActiveRecord::RecordNotUnique
      # Ignore
    end
  end
end
