class DiscussionPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user_signed_in?
  end

  def new?
    create?
  end

  def update?
    return false unless user_signed_in?
    return true if moderator?

    owner? && !record.locked? && !record.archived?
  end

  def edit?
    update?
  end

  def destroy?
    return false unless user_signed_in?

    owner? || moderator?
  end

  def lock?
    moderator?
  end

  def unlock?
    moderator?
  end

  def pin?
    moderator?
  end

  def unpin?
    moderator?
  end

  def archive?
    moderator?
  end

  def restore?
    moderator?
  end

  class Scope < Scope
    def resolve
      if moderator?
        scope.all
      else
        scope.where.not(status: :archived)
      end
    end
  end
end
