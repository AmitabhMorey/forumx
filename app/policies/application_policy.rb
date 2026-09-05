# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  protected

  def user_signed_in?
    user.present? && !user.suspended?
  end

  def admin?
    user_signed_in? && user.admin?
  end

  def moderator?
    user_signed_in? && user.can_moderate?
  end

  def owner?
    user_signed_in? && record.respond_to?(:user_id) && record.user_id == user.id
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    protected

    attr_reader :user, :scope

    def user_signed_in?
      user.present? && !user.suspended?
    end

    def moderator?
      user_signed_in? && user.can_moderate?
    end

    def admin?
      user_signed_in? && user.admin?
    end
  end
end
