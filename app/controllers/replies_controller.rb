class RepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discussion
  before_action :set_reply, only: [:destroy, :accept]

  def create
    @reply = @discussion.replies.build(reply_params.merge(user: current_user))
    authorize @reply

    result = Replies::CreateService.call(
      user: current_user,
      discussion: @discussion,
      params: reply_params
    )

    if result.success?
      @reply = result.reply
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to discussion_path(@discussion, anchor: "reply-#{@reply.id}"), notice: "Reply posted!" }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("reply-form", partial: "replies/form",
                                                                  locals: { discussion: @discussion, reply: @reply, parent_reply_id: reply_params[:parent_reply_id] })
        end
        format.html { redirect_to discussion_path(@discussion), alert: result.errors.to_sentence }
      end
    end
  end

  def destroy
    authorize @reply
    @reply.destroy!

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("reply-#{@reply.id}") }
      format.html { redirect_to discussion_path(@discussion), notice: "Reply deleted." }
    end
  end

  def accept
    authorize @reply, :accept?

    result = Discussions::AcceptAnswerService.call(
      user: current_user,
      discussion: @discussion,
      reply: @reply
    )

    if result.success?
      respond_to do |format|
        format.turbo_stream
        format.html do
          redirect_to discussion_path(@discussion), notice: result.accepted ? "Marked as accepted answer!" : "Answer unaccepted."
        end
      end
    else
      redirect_to discussion_path(@discussion), alert: result.error
    end
  end

  private

  def set_discussion
    @discussion = Discussion.find_by!(slug: params.expect(:discussion_id))
  end

  def set_reply
    @reply = @discussion.replies.find(params.expect(:id))
  end

  def reply_params
    params.expect(reply: [:body, :parent_reply_id])
  end
end
