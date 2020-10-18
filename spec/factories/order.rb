# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    status { 0 }

    trait :created do
      status { 0 }
    end

    trait :accepted do
      status { 1 }
    end

    trait :in_process do
      status { 2 }
    end

    trait :finished do
      status { 3 }
    end

    trait :cancelled do
      status { 4 }
    end
  end
end
