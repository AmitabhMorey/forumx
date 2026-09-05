class ReportsController < ApplicationController
  before_action :authenticate_user!

  def new
    @reportable = find_reportable
    return redirect_back_or_to(root_path, alert: "Item to report was not found.") unless @reportable

    @report = Report.new(reportable: @reportable)
    authorize @report
  end

  def create
    @reportable = find_reportable
    return redirect_back_or_to(root_path, alert: "Item to report was not found.") unless @reportable

    @report = Report.new(report_params.merge(reporter: current_user, reportable: @reportable))
    authorize @report

    if @report.save
      redirect_back_or_to(root_path, notice: "Thank you for reporting. Our moderation team will review it.")
    else
      redirect_back_or_to(root_path, alert: @report.errors.full_messages.to_sentence)
    end
  end

  private

  def find_reportable
    type = params[:reportable_type].to_s
    id = params[:reportable_id]

    case type
    when "Discussion"
      Discussion.find_by(id: id)
    when "Reply"
      Reply.find_by(id: id)
    when "User"
      User.find_by(id: id)
    end
  end

  def report_params
    params.expect(report: [:reason, :description])
  end
end
