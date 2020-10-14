FactoryBot.define do
    factory :volunteer_rating do
        score { Faker::Number.number(digits: 1) }
        comment { Faker::Lorem.sentence }
    end
end
  