# frozen_string_literal: true
# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  pos        :string
#  rating     :integer
#  start      :integer
#  stop       :integer
#  subbed_out :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id   (match_id)
#  index_caps_on_player_id  (player_id)
#

FactoryBot.define do
  factory :cap do
    pos { Cap::POSITIONS.sample }
    start { Faker::Number.between(from: 0, to: 90) }
    stop { Faker::Number.between(from: start || 0, to: 90) }
    player
    match { Match.new(attributes_for(:match, team_id: player.team_id)) }
  end
end
