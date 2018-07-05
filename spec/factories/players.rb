# == Schema Information
#
# Table name: players
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text
#  ovr         :integer
#  value       :integer
#  birth_year  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#  youth       :boolean          default(TRUE)
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

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

    transient do
      contracts_count 1
      injuries_count 0
      loans_count 0
    end

    after :create do |player, evaluator|
      evaluator.contracts_count.times do
        player.contracts.create(attributes_for(:contract))
      end
      # create_list :contract, evaluator.contracts_count, player: player
      create_list :injury, evaluator.injuries_count, player: player
      create_list :loan, evaluator.loans_count, player: player
    end
  end
end
