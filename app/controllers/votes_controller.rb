class VotesController < ApplicationController
  before_action :authenticate_user!

  def create
    @voteable = find_voteable
    return redirect_back_or_to(root_path, alert: "Target not found") unless @voteable

    result = Votes::VoteService.call(
      user: current_user,
      voteable: @voteable,
      value: params[:value]
    )

    if result.success?
      @vote_score = result.vote_score
      @user_vote = result.user_vote

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_back_or_to(root_path) }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("flash-container", partial: "shared/flash", locals: { alert: result.error })
        end
        format.html { redirect_back_or_to(root_path, alert: result.error) }
      end
    end
  end

  private

  def find_voteable
    case params[:voteable_type].to_s.downcase
    when "discussion"
      Discussion.find_by(id: params[:voteable_id])
    when "reply"
      Reply.find_by(id: params[:voteable_id])
    end
  end
end
