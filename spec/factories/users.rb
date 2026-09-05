FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user_#{n}" }
    sequence(:email) { |n| "user_#{n}@example.com" }
    display_name { Faker::Name.name }
    password { "Password123!" }
    password_confirmation { "Password123!" }
    role { :user }
    reputation { 0 }

    trait :moderator do
      role { :moderator }
    end

    trait :admin do
      role { :admin }
    end

    trait :suspended do
      suspended_at { Time.current }
    end
  end
end
