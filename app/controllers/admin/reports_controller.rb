module Admin
  class ReportsController < BaseController
    before_action :set_report, only: [:show, :resolve, :dismiss]

    def index
      @status = params[:status].presence || "pending"
      @reports = Report.includes(:reporter, :reportable)

      @reports = case @status
                 when "resolved"
                   @reports.resolved
                 when "dismissed"
                   @reports.dismissed
                 else
                   @reports.pending
                 end

      @reports = @reports.recent.page(params[:page]).per(20)
    end

    def show; end

    def resolve
      @report.resolve!(current_user)
      ModerationLog.create!(
        moderator: current_user,
        action: "resolve_report",
        target_type: "Report",
        target_id: @report.id,
        reason: "Report ##{@report.id} resolved",
        metadata: { reason: @report.reason }
      )
      redirect_back_or_to(admin_reports_path, notice: "Report ##{@report.id} resolved.")
    end

    def dismiss
      @report.dismiss!(current_user)
      ModerationLog.create!(
        moderator: current_user,
        action: "dismiss_report",
        target_type: "Report",
        target_id: @report.id,
        reason: "Report ##{@report.id} dismissed",
        metadata: { reason: @report.reason }
      )
      redirect_back_or_to(admin_reports_path, notice: "Report ##{@report.id} dismissed.")
    end

    private

    def set_report
      @report = Report.find(params.expect(:id))
    end
  end
end
