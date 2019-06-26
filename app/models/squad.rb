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
  has_many :squad_players, dependent: :destroy
  has_many :players, through: :squad_players

  PERMITTED_ATTRIBUTES = %i[
    name
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :name, presence: true
  validates :squad_players, length: { is: 11 }

  accepts_nested_attributes_for :squad_players
end
