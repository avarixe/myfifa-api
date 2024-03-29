# frozen_string_literal: true

# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  injured    :boolean          default(FALSE), not null
#  ovr        :integer
#  pos        :string
#  rating     :integer
#  start      :integer          default(0)
#  stop       :integer          default(90)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  next_id    :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id                          (match_id)
#  index_caps_on_next_id                           (next_id)
#  index_caps_on_player_id                         (player_id)
#  index_caps_on_player_id_and_match_id_and_start  (player_id,match_id,start) UNIQUE
#  index_caps_on_pos_and_match_id_and_start        (pos,match_id,start) UNIQUE
#

FactoryBot.define do
  factory :cap do
    pos { Cap::POSITIONS.sample }
    start { 0 }
    stop { Faker::Number.between(from: start || 0, to: 90) }
    player
    match { Match.new(attributes_for(:match, team_id: player.team_id)) }
  end
end
