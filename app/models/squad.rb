# frozen_string_literal: true

# == Schema Information
#
# Table name: squads
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

class Squad < ApplicationRecord
  include Broadcastable

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
  validate :unique_positions?
  validate :unique_players?

  def unique_positions?
    return if squad_players.map(&:pos).uniq.size == 11

    errors.add :squad, 'includes at least one Position multiple times'
  end

  def unique_players?
    return if squad_players.map(&:player_id).uniq.size == 11

    errors.add :base, 'includes at least one Player multiple times'
  end

  accepts_nested_attributes_for :squad_players

  def as_json(options = {})
    options[:include] ||= []
    options[:include] += [:squad_players]
    super
  end
end
