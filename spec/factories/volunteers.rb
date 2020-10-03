FactoryBot.define do
  factory :volunteer, parent: :user do
    :document_type
    document_number { Faker::Number.number(digits: 8) }
  end
end
