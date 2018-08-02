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

  def eleven_players?
    return if players_list.length == 11 &&
              positions_list.length == 11 &&
              positions_list.all? { |pos| valid_pos? pos }
    errors.add(:players_list, 'needs to have eleven Players.')
  end

  def valid_pos?(pos)
    Performance::POSITIONS.include? pos
  end
end
