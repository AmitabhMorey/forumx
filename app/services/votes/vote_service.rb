module Votes
  class VoteService
    Result = Struct.new(:success, :vote_score, :user_vote, :voteable, :error, keyword_init: true) do
      def success?
        success
      end
    end

    def self.call(user:, voteable:, value:)
      new(user: user, voteable: voteable, value: value.to_i).call
    end

    def initialize(user:, voteable:, value:)
      @user = user
      @voteable = voteable
      @value = value
    end

    def call
      return Result.new(success: false, error: "Must be logged in to vote") unless @user
      return Result.new(success: false, error: "You cannot vote on your own content") if @voteable.user_id == @user.id
      return Result.new(success: false, error: "Invalid vote value") unless [-1, 1].include?(@value)

      target_author = @voteable.user
      user_current_vote = nil

      ActiveRecord::Base.transaction do
        existing_vote = @voteable.votes.find_by(user: @user)

        if existing_vote
          if existing_vote.value == @value
            # User clicked same button again -> Reset to Neutral
            existing_vote.destroy!
            user_current_vote = 0

            # Revert reputation
            rep_delta = @value == 1 ? -2 : 1
          else
            # User switched from upvote to downvote or vice-versa
            existing_vote.update!(value: @value)
            user_current_vote = @value

            # Adjust reputation difference
            rep_delta = @value == 1 ? 3 : -3
          end
        else
          # New vote
          @voteable.votes.create!(user: @user, value: @value)
          user_current_vote = @value

          # Award or deduct reputation
          rep_delta = @value == 1 ? 2 : -1
        end
        target_author.increment!(:reputation, rep_delta)

        # Recalculate and cache vote_score
        new_score = @voteable.votes.sum(:value)
        @voteable.update_columns(vote_score: new_score)

        # Check badges for target author if reputation increased
        Badges::BadgeAwarder.check_and_award!(target_author)

        Result.new(
          success: true,
          vote_score: new_score,
          user_vote: user_current_vote,
          voteable: @voteable
        )
      end
    rescue StandardError => e
      Result.new(success: false, error: e.message)
    end
  end
end
