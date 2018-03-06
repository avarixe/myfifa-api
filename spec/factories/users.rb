FactoryBot.define do
  factory :user do
    full_name Faker::Name.name
    email Faker::Internet.unique.email
    password Faker::Internet.password
  end
end