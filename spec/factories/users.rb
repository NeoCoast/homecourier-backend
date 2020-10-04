FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
    username { Faker::Internet.username(specifier: 8) }
    name { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 100) }
    address { Faker::Address.street_address }
  end
end
