FactoryBot.define do
  factory :player do
    name Faker::Name.name
    pos Player::POSITIONS.sample
    nationality Faker::Address.country
    sec_pos []
    age Faker::Number.between(18, 40)
    ovr Faker::Number.between(50, 90)
    value Faker::Number.between(50_000, 200_000_000)
    team
  end
end