require 'rails_helper'

RSpec.describe Replies::CreateService do
  let(:author) { create(:user) }
  let(:replier) { create(:user, reputation: 0) }
  let(:subscriber) { create(:user) }
  let(:discussion) { create(:discussion, user: author) }

  before do
    subscriber.subscriptions.create!(discussion: discussion)
  end

  it "posts reply, awards +2 reputation to replier, and notifies author and subscribers" do
    result = described_class.call(
      user: replier,
      discussion: discussion,
      params: { body: "This is a solution to your problem!" }
    )

    expect(result.success?).to be true
    expect(replier.reload.reputation).to eq(2)

    # Author notification
    author_notif = Notification.find_by(recipient: author, action: "reply")
    expect(author_notif).to be_present
    expect(author_notif.actor).to eq(replier)

    # Subscriber notification
    sub_notif = Notification.find_by(recipient: subscriber, action: "subscription")
    expect(sub_notif).to be_present
  end

  it "refuses to add reply when discussion is locked" do
    discussion.update!(status: :locked)

    result = described_class.call(
      user: replier,
      discussion: discussion,
      params: { body: "Attempting to post on locked thread" }
    )

    expect(result.success?).to be false
    expect(result.errors).to include("Discussion is locked and cannot receive new replies.")
  end
end
