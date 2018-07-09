# == Schema Information
#
# Table name: squads
#
#  id             :integer          not null, primary key
#  team_id        :integer
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
    list
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :name, presence: true
  validate :eleven_players?

  def eleven_players?
    return if list.length == 11
    errors.add(:list, 'needs to have eleven Players.')
  end
end
