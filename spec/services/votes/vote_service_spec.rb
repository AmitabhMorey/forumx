require 'rails_helper'

RSpec.describe Votes::VoteService do
  let(:author) { create(:user, reputation: 10) }
  let(:voter) { create(:user) }
  let(:discussion) { create(:discussion, user: author, vote_score: 0) }

  describe ".call" do
    it "casts an upvote, updates score, and awards reputation to author" do
      result = described_class.call(user: voter, voteable: discussion, value: 1)
      expect(result.success?).to be true
      expect(result.vote_score).to eq(1)
      expect(result.user_vote).to eq(1)
      expect(discussion.reload.vote_score).to eq(1)
      expect(author.reload.reputation).to eq(12) # +2
    end

    it "toggles vote to neutral when same button is clicked again" do
      described_class.call(user: voter, voteable: discussion, value: 1)
      result = described_class.call(user: voter, voteable: discussion, value: 1)
      expect(result.success?).to be true
      expect(result.vote_score).to eq(0)
      expect(result.user_vote).to eq(0)
      expect(discussion.reload.vote_score).to eq(0)
      expect(author.reload.reputation).to eq(10) # Reverted back
    end

    it "switches vote from upvote to downvote and adjusts reputation accordingly" do
      described_class.call(user: voter, voteable: discussion, value: 1) # rep: 12
      result = described_class.call(user: voter, voteable: discussion, value: -1)
      expect(result.success?).to be true
      expect(result.vote_score).to eq(-1)
      expect(result.user_vote).to eq(-1)
      expect(author.reload.reputation).to eq(9) # 10 - 1 = 9
    end

    it "refuses self-voting" do
      result = described_class.call(user: author, voteable: discussion, value: 1)
      expect(result.success?).to be false
      expect(result.error).to eq("You cannot vote on your own content")
    end
  end
end
