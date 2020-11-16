# frozen_string_literal: true

require './spec/support/geocoder_stub'

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
    username { Faker::Internet.username(specifier: 8) }
    name { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    birth_date { Faker::Date.birthday(min_age: 19, max_age: 100).strftime('%d/%m/%Y') }
    address { Faker::Address.street_address }
    confirmation_token { Faker::Internet.password(min_length: 20) }
    enabled { true }

    after(:build) { GeocoderStub.stub_with }
  end
end
