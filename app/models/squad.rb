# frozen_string_literal: true

# == Schema Information
#
# Table name: squads
#
#  id             :bigint(8)        not null, primary key
#  team_id        :bigint(8)
#  name           :string
#  players_list   :text             default([]), is an Array
#  positions_list :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

class Squad < ApplicationRecord
  belongs_to :team

  PERMITTED_ATTRIBUTES = %i[
    name
    players_list
    positions_list
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :name, presence: true
  validate :eleven_players?
  validate :unique_players?
  validate :valid_players?

  def eleven_players?
    return if players_list.length == 11 &&
              positions_list.length == 11 &&
              positions_list.all? { |pos| valid_pos? pos }

    errors.add :players_list, 'needs to have eleven Players.'
  end

  def unique_players?
    return if players_list.uniq.length == 11

    errors.add :players_list, 'can\'t assign a Player to multiple Positions.'
  end

  def valid_players?
    valid_ids = team.players.pluck(:id).map(&:to_s)
    return if (players_list & valid_ids) == players_list

    errors.add :players_list, 'contains invalid Players'
  end

  def valid_pos?(pos)
    Performance::POSITIONS.include? pos
  end
end
