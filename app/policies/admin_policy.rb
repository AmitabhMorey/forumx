class AdminPolicy < ApplicationPolicy
  def dashboard?
    moderator?
  end

  def manage_users?
    admin?
  end

  def manage_categories?
    admin?
  end

  def manage_discussions?
    moderator?
  end

  def manage_replies?
    moderator?
  end

  def manage_reports?
    moderator?
  end

  def manage_moderation?
    moderator?
  end
end
