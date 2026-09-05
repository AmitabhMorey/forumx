FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    sequence(:slug) { |n| "category-#{n}" }
    description { "Discussion category description" }
    color_accent { "#4f46e5" }
    position { 1 }
  end

  factory :tag do
    sequence(:name) { |n| "tag#{n}" }
    sequence(:slug) { |n| "tag#{n}" }
  end

  factory :badge do
    sequence(:name) { |n| "Badge #{n}" }
    sequence(:slug) { |n| "badge-#{n}" }
    description { "Earned for special contribution" }
    icon { "trophy" }
    badge_type { "bronze" }
  end
end
