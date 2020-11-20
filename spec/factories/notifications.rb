# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    user_id { Faker::Number.between(from: 1, to: 100) }
    title { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    order_id { Faker::Number.between(from: 1, to: 100) }
  end
end
