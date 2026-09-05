require 'rails_helper'

RSpec.describe Discussion, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "slug generation" do
    it "automatically generates unique parameterized slug from title" do
      category = create(:category)
      user = create(:user)
      discussion1 = create(:discussion, title: "How to Master Ruby on Rails", category: category, user: user)
      expect(discussion1.slug).to eq("how-to-master-ruby-on-rails")

      discussion2 = create(:discussion, title: "How to Master Ruby on Rails", category: category, user: user)
      expect(discussion2.slug).to eq("how-to-master-ruby-on-rails-1")
    end
  end

  describe "accepted answers" do
    let(:user) { create(:user) }
    let(:category) { create(:category) }
    let(:discussion) { create(:discussion, user: user, category: category) }
    let(:reply) { create(:reply, discussion: discussion) }

    it "accepts a reply as the official answer" do
      discussion.accept_reply!(reply)
      expect(discussion.reload.accepted_reply_id).to eq(reply.id)
      expect(discussion.resolved?).to be true
      expect(reply.reload.is_accepted?).to be true
    end

    it "unaccepts an answer correctly" do
      discussion.accept_reply!(reply)
      discussion.unaccept_reply!
      expect(discussion.reload.accepted_reply_id).to be_nil
      expect(discussion.open?).to be true
      expect(reply.reload.is_accepted?).to be false
    end
  end
end
