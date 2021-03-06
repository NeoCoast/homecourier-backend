# frozen_string_literal: true

FactoryBot.define do
  factory :helpee_rating do
    score { 5 }
    comment { Faker::Lorem.sentence }
  end
end
