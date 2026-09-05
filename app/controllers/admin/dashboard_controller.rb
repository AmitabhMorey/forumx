module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @active_users = User.active.where(updated_at: 7.days.ago..).count
      @total_discussions = Discussion.count
      @total_replies = Reply.count
      @pending_reports_count = Report.pending.count
      @new_users_this_week = User.where(created_at: 1.week.ago..).count
      @discussions_this_week = Discussion.where(created_at: 1.week.ago..).count
      @replies_this_week = Reply.where(created_at: 1.week.ago..).count

      @recent_reports = Report.pending.includes(:reporter, :reportable).recent.limit(5)
      @recent_moderation_logs = ModerationLog.includes(:moderator).recent.limit(5)
      @recent_discussions = Discussion.includes(:user, :category).latest.limit(5)
    end

    def statistics
      @users_by_day = User.where(created_at: 30.days.ago..)
                          .group("DATE(created_at)")
                          .count
      @discussions_by_day = Discussion.where(created_at: 30.days.ago..)
                                      .group("DATE(created_at)")
                                      .count
      @replies_by_day = Reply.where(created_at: 30.days.ago..)
                             .group("DATE(created_at)")
                             .count
      @category_counts = Category.joins(:discussions).group("categories.name").count
      @reports_by_reason = Report.group(:reason).count
    end
  end
end
