# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer, parent: :user do
    type { 'Volunteer' }
    :document_type
    document_number { Faker::Number.number(digits: 8) }
  end
end
