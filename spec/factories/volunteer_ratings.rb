FactoryBot.define do
  factory :volunteer_rating do
    score { 4 }
    comment { Faker::Lorem.sentence }
  end
end
