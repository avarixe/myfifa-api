# == Schema Information
#
# Table name: matches
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  home        :string
#  away        :string
#  competition :string
#  date_played :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

class Match < ApplicationRecord
  attr_accessor :line_up

  belongs_to :team
  has_one :penalty_shootout
  has_many :goals
  has_many :substitutions
  has_many :bookings

  has_many :logs, class_name: 'MatchLog', inverse_of: :match
  has_many :players, through: :logs

  PERMITTED_ATTRIBUTES = %i[
    home
    away
    competition
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  ################
  #  VALIDATION  #
  ################

  validates :home, presence: true
  validates :away, presence: true
  validates :competition, presence: true
  validates :date_played, presence: true
  validates :line_up, presence: true
  validate :valid_line_up?

  def valid_line_up?
    if !line_up.is_a?(Array) ||
       [0, 11].include?(line_up.length) ||
       line_up.any? { |player| invalid_start?(player) }
      errors.add(:line_up, :invalid)
    end
  end

  def invalid_start?(player)
    player.is_a?(Hash) &&
    player[:id].present? &&
    player[:position].present?
  end

  ##############
  #  CALLBACK  #
  ##############

  after_initialize :set_defaults

  def set_defaults
    self.date_played ||= team.current_date
    @line_up ||= []
  end

  ##############
  #  MUTATORS  #
  ##############

  ###############
  #  ACCESSORS  #
  ###############

  def score
    total_goals = goals.count
    home_score = goals.count { |goal| goal.home? || goal.away? && goal.own_goal? }
    away_score = total_goals - home_goals

    if penalty_shootout
      home_score += " (#{ penalty_shootout.home_score })"
      away_score += " (#{ penalty_shootout.away_score })"
    end

    "#{ home_score } - #{ away_score }"
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ score ]
    }))
  end

end
