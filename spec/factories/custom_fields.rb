FactoryBot.define do
  factory :custom_field do
    association :client
    sequence(:name) { |n| "custom_field_#{n}" }
    field_type { "freeform" }

    trait :number do
      field_type { "number" }
    end

    trait :enum do
      field_type { "enum" }
      enum_options { ["Option 1", "Option 2", "Option 3"] }
    end
  end
end
