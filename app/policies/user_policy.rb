class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def update?
    return false unless user_signed_in?

    user.id == record.id || admin?
  end

  def edit?
    update?
  end

  def suspend?
    return false unless moderator?
    return false if user.id == record.id
    return false if record.admin? && !admin?

    true
  end

  def unsuspend?
    suspend?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
