require 'rails_helper'

RSpec.describe Discussions::CreateService do
  let(:user) { create(:user, reputation: 0) }
  let(:category) { create(:category) }
  let!(:mentioned_user) { create(:user, username: "sarah_test") }

  it "creates discussion, awards +5 reputation, subscribes author, and parses mentions" do
    params = {
      title: "How to configure Sidekiq in Rails?",
      category_id: category.id,
      body: "Hello @sarah_test, what do you think about this Sidekiq configuration?",
      tag_names: "ruby, rails, sidekiq"
    }

    result = described_class.call(user: user, params: params)
    expect(result.success?).to be true
    discussion = result.discussion

    expect(discussion.persisted?).to be true
    expect(discussion.tags.pluck(:name)).to match_array(%w[ruby rails sidekiq])
    expect(user.reload.reputation).to eq(5)
    expect(user.subscribed?(discussion)).to be true

    # Notification for mentioned user
    notification = Notification.find_by(recipient: mentioned_user, action: "mention")
    expect(notification).to be_present
    expect(notification.actor).to eq(user)
  end
end
