# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    description { Faker::Lorem.sentence }
  end
end
