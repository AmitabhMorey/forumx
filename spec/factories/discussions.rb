FactoryBot.define do
  factory :discussion do
    association :user
    association :category
    sequence(:title) { |n| "Discussion Title Sample #{n}" }
    sequence(:slug) { |n| "discussion-title-sample-#{n}" }
    body { "This is a detailed technical discussion post for testing purposes." }
    status { :open }
    pinned { false }
    view_count { 0 }
    vote_score { 0 }

    trait :locked do
      status { :locked }
    end

    trait :resolved do
      status { :resolved }
    end

    trait :pinned do
      pinned { true }
    end
  end

  factory :reply do
    association :discussion
    association :user
    body { "This is a helpful technical response to the topic." }
    vote_score { 0 }
    is_accepted { false }
    status { :visible }

    trait :accepted do
      is_accepted { true }
    end
  end

  factory :vote do
    association :user
    association :voteable, factory: :discussion
    value { 1 }
  end

  factory :report do
    association :reporter, factory: :user
    association :reportable, factory: :discussion
    reason { "Spam" }
    description { "Test report description" }
    status { :pending }
  end
end
