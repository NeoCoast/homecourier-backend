# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    description { Faker::Lorem.sentence }
  end
end
