module Admin
  class ModerationLogsController < BaseController
    def index
      @logs = ModerationLog.includes(:moderator).recent.page(params[:page]).per(25)
    end
  end
end
