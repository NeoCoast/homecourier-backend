FactoryBot.define do
  factory :category do
    description { Faker::Lorem.sentence }
  end
end
