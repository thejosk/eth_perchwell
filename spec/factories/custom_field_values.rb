FactoryBot.define do
  factory :custom_field_value do
    association :building
    association :custom_field
    value { "test value" }
  end
end
