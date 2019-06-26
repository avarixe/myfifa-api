# frozen_string_literal: true

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

class SquadPlayer < ApplicationRecord
  belongs_to :squad
  belongs_to :player

  validates :pos,
            inclusion: { in: Cap::POSITIONS },
            uniqueness: { scope: :squad }
  validates :player_id,
            uniqueness: { scope: :squad }
  validate :same_team?

  def same_team?
    return if squad_id.nil? ||
              player_id.nil? ||
              squad.team_id == player.team_id

    errors.add :base, 'Squad and Player are not of the same Team'
  end
end
