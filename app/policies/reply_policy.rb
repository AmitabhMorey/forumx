class ReplyPolicy < ApplicationPolicy
  def create?
    return false unless user_signed_in?

    discussion = record.discussion
    !discussion.locked? && !discussion.archived?
  end

  def new?
    create?
  end

  def update?
    return false unless user_signed_in?
    return true if moderator?

    discussion = record.discussion
    owner? && !discussion.locked? && !discussion.archived?
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user_signed_in?

    owner? || moderator?
  end

  def accept?
    return false unless user_signed_in?

    # Only discussion author can accept
    record.discussion.user_id == user.id
  end

  class Scope < Scope
    def resolve
      if moderator?
        scope.all
      else
        scope.where(status: :visible)
      end
    end
  end
end
