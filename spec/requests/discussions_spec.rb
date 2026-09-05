require 'rails_helper'

RSpec.describe "Discussions", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:discussion) { create(:discussion, user: user, category: category) }

  describe "GET /discussions" do
    it "renders the discussions list successfully" do
      get discussions_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Community Discussions")
    end
  end

  describe "GET /discussions/:id" do
    it "renders the discussion page and increments view count" do
      expect do
        get discussion_path(discussion)
      end.to change { discussion.reload.view_count }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(discussion.title)
    end
  end

  describe "POST /discussions" do
    context "when authenticated" do
      before { sign_in user }

      it "creates a new discussion" do
        expect do
          post discussions_path, params: {
            discussion: {
              title: "New Architectural Discussion",
              category_id: category.id,
              body: "Here is a complete description of the technical question.",
              tag_names: "ruby, rails"
            }
          }
        end.to change(Discussion, :count).by(1)

        expect(response).to redirect_to(discussion_path(Discussion.last))
      end
    end

    context "when unauthenticated" do
      it "redirects to the sign in page" do
        post discussions_path, params: {
          discussion: { title: "Test", category_id: category.id, body: "Test body" }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /discussions/:id/bookmark" do
    before { sign_in user }

    it "toggles bookmark on and off" do
      post bookmark_discussion_path(discussion)
      expect(user.bookmarked?(discussion)).to be true

      post bookmark_discussion_path(discussion)
      expect(user.bookmarked?(discussion)).to be false
    end
  end

  describe "POST /discussions/:id/subscribe" do
    before { sign_in user }

    it "toggles subscription on and off" do
      post subscribe_discussion_path(discussion)
      expect(user.subscribed?(discussion)).to be true

      post subscribe_discussion_path(discussion)
      expect(user.subscribed?(discussion)).to be false
    end
  end
end
