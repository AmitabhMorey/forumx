class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    @recent_discussions = current_user.discussions.latest.limit(5)
    @recent_replies = current_user.replies.includes(:discussion).chronological.reverse_order.limit(5)
    @bookmarked_count = current_user.bookmarks.count
    @subscriptions_count = current_user.subscriptions.count
    @badges = current_user.badges
  end

  def my_discussions
    @discussions = current_user.discussions
                               .includes(:category, :tags)
                               .latest
                               .page(params[:page])
                               .per(15)
  end

  def my_replies
    @replies = current_user.replies
                           .includes(:discussion)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(15)
  end
end
