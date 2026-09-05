require 'rails_helper'

RSpec.describe "Votes", type: :request do
  let(:author) { create(:user) }
  let(:voter) { create(:user) }
  let(:discussion) { create(:discussion, user: author) }

  context "when signed in" do
    before { sign_in voter }

    it "records an upvote successfully" do
      expect do
        post vote_path(voteable_type: "Discussion", voteable_id: discussion.id, value: 1)
      end.to change(Vote, :count).by(1)

      expect(discussion.reload.vote_score).to eq(1)
    end
  end

  context "when unauthenticated" do
    it "redirects to sign in" do
      post vote_path(voteable_type: "Discussion", voteable_id: discussion.id, value: 1)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
