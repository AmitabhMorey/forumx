class ReportPolicy < ApplicationPolicy
  def index?
    moderator?
  end

  def show?
    moderator?
  end

  def create?
    return false unless user_signed_in?

    # Disallow reporting own content
    target_owner_id = record.reportable.try(:user_id) || (record.reportable.is_a?(User) ? record.reportable.id : nil)
    target_owner_id != user.id
  end

  def new?
    create?
  end

  def resolve?
    moderator?
  end

  def dismiss?
    moderator?
  end
end
