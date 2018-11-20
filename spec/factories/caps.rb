# frozen_string_literal: true
# == Schema Information
#
# Table name: caps
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  start      :integer
#  stop       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subbed_out :boolean          default(FALSE)
#  rating     :integer
#
# Indexes
#
#  index_caps_on_match_id   (match_id)
#  index_caps_on_player_id  (player_id)
#

FactoryBot.define do
  factory :cap do
    pos { Cap::POSITIONS.sample }
    start { Faker::Number.between(0, 89) }
    stop { Faker::Number.between(90, 120) }
    player
    match { Match.new(attributes_for(:match, team_id: player.team_id)) }
  end
end
