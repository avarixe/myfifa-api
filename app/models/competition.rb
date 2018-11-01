# frozen_string_literal: true

# == Schema Information
#
# Table name: competitions
#
#  id         :bigint(8)        not null, primary key
#  team_id    :bigint(8)
#  season     :integer
#  name       :string
#  champion   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_competitions_on_season   (season)
#  index_competitions_on_team_id  (team_id)
#

class Competition < ApplicationRecord
  belongs_to :team
  has_many :stages, dependent: :destroy

  ATTR_ACCESSORS = %i[
    preset_format
    num_teams
    num_teams_per_group
    num_advances_from_group
    num_matches_per_fixture
  ].freeze

  attr_accessor(*ATTR_ACCESSORS)

  PERMITTED_ATTRIBUTES = %i[
    season
    name
    champion
    preset
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES + ATTR_ACCESSORS
  end

  ################
  #  VALIDATION  #
  ################

  validates :season, presence: true
  validates :name, presence: true
  validate :valid_preset_format?, if: :preset_format

  def valid_preset_format?
    return if
      case preset_format
      when 'League'           then valid_league?
      when 'Knockout'         then valid_knockout_stage?
      when 'Group + Knockout' then valid_group_knockout_stages?
      end

    errors.add(:base, 'Preset Format parameters are invalid')
  end

  def valid_league?
    num_teams.to_i > 1
  end

  def valid_knockout_stage?
    num_teams &&
      num_matches_per_fixture.positive? &&
      2**num_rounds == num_knockout_teams
  end

  def valid_group_knockout_stages?
    num_teams &&
      num_teams_per_group &&
      num_advances_from_group &&
      num_matches_per_fixture.positive? &&
      num_groups * num_teams_per_group == num_teams &&
      2**num_rounds == num_knockout_teams
  end

  ##############
  #  CALLBACK  #
  ##############

  after_save :load_preset_format, if: :preset_format

  def load_preset_format
    # clear existing stages
    stages.map(&:destroy)

    case preset_format
    when 'League'           then load_league
    when 'Knockout'         then load_knockout_stage
    when 'Group + Knockout' then load_group_knockout_stages
    end
  end

  def load_league
    stages.create name: 'League Table',
                  num_teams: num_teams,
                  table: true
  end

  def load_knockout_stage
    num_rounds.times do |i|
      num_round_teams = num_knockout_teams / 2**i
      stages.create num_teams: num_round_teams,
                    num_fixtures: num_round_teams * num_matches_per_fixture / 2
    end
  end

  def load_group_stage
    num_groups.times do |i|
      stages.create name: "Group #{('A'.ord + i).chr}",
                    num_teams: num_teams_per_group,
                    table: true
    end
  end

  def load_group_knockout_stages
    load_group_stage
    load_knockout_stage
  end

  ##############
  #  MUTATORS  #
  ##############

  %w[
    num_teams
    num_teams_per_group
    num_advances_from_group
    num_matches_per_fixture
  ].each do |var|
    define_method "#{var}=" do |val|
      instance_variable_set "@#{var}", val.to_i
    end
  end

  ###############
  #  ACCESSORS  #
  ###############

  def num_groups
    @num_groups ||= (num_teams / num_teams_per_group).to_i
  end

  def num_advances
    @num_advances ||= (num_groups * num_advances_from_group).to_i
  end

  def num_knockout_teams
    @num_knockout_teams ||=
      if num_advances_from_group.zero?
        num_teams
      else
        num_advances
      end
  end

  def num_rounds
    @num_rounds ||= Math.log(num_knockout_teams, 2).to_i
  end
end
