# == Schema Information
#
# Table name: squad_players
#
#  id         :bigint(8)        not null, primary key
#  squad_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_squad_players_on_player_id  (player_id)
#  index_squad_players_on_squad_id   (squad_id)
#

FactoryBot.define do
  factory :squad_player do
    pos { Cap::POSITIONS.sample }
    player
    squad { Squad.new(attributes_for(:squad, team_id: player.team_id)) }
  end
end
