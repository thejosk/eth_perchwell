FactoryBot.define do
  factory :building do
    association :client
    sequence(:street) { |n| "#{n} Main St" }
    city { "Test City" }
    state { "NY" }
    zip { "10000" }
    country { "USA" }
  end
end
