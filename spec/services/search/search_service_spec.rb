require 'rails_helper'

RSpec.describe Search::SearchService do
  let!(:category1) { create(:category, name: "Ruby Development", slug: "ruby-dev") }
  let!(:category2) { create(:category, name: "Cybersecurity", slug: "cybersecurity") }
  let!(:user) { create(:user, username: "dev_expert") }

  let!(:disc1) do
    create(:discussion,
           title: "Mastering Metaprogramming in Ruby",
           body: "Learn how define_method and method_missing function under the hood.",
           category: category1,
           user: user)
  end

  let!(:disc2) do
    create(:discussion,
           title: "Network Penetration Testing with Wireshark",
           body: "Analyzing packet headers and SSL certificates for security flaws.",
           category: category2)
  end

  it "finds discussions by full-text keyword query" do
    service = described_class.new(query: "metaprogramming")
    results = service.discussions
    expect(results).to include(disc1)
    expect(results).not_to include(disc2)
  end

  it "filters discussions by category slug" do
    service = described_class.new(category_slug: "cybersecurity")
    results = service.discussions
    expect(results).to include(disc2)
    expect(results).not_to include(disc1)
  end

  it "finds matching users by username" do
    service = described_class.new(query: "dev_expert")
    expect(service.users).to include(user)
  end
end
