class HomeController < ApplicationController
  def index
    @trending_discussions = Discussion.includes(:user, :category, :tags).trending.limit(5)
    @latest_discussions = Discussion.includes(:user, :category, :tags).latest.limit(8)
    @popular_categories = Category.ordered.limit(6)
    @top_contributors = User.active.top_contributors.limit(5)

    # Community statistics
    @stats = {
      total_users: User.active.count,
      total_discussions: Discussion.count,
      total_replies: Reply.count,
      active_users: User.active.where(updated_at: 7.days.ago..).count
    }
  end
end
