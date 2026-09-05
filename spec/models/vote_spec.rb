require 'rails_helper'

RSpec.describe Vote, type: :model do
  let(:author) { create(:user) }
  let(:voter) { create(:user) }
  let(:discussion) { create(:discussion, user: author) }

  it "allows a user to vote on another member's discussion" do
    vote = build(:vote, user: voter, voteable: discussion, value: 1)
    expect(vote).to be_valid
  end

  it "prevents a user from voting on their own content" do
    self_vote = build(:vote, user: author, voteable: discussion, value: 1)
    expect(self_vote).not_to be_valid
    expect(self_vote.errors[:base]).to include("You cannot vote on your own content")
  end

  it "prevents duplicate voting by the same user on the same item" do
    create(:vote, user: voter, voteable: discussion, value: 1)
    dup_vote = build(:vote, user: voter, voteable: discussion, value: 1)
    expect(dup_vote).not_to be_valid
  end
end
