# == Schema Information
#
# Table name: matches
#
#  id                  :integer          not null, primary key
#  team_id             :integer
#  home                :string
#  away                :string
#  competition         :string
#  date_played         :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  extra_time          :boolean          default(FALSE)
#  home_score_override :integer
#  away_score_override :integer
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

class Match < ApplicationRecord
  attr_accessor :line_up

  belongs_to :team
  has_one :penalty_shootout, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :substitutions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  has_many :logs, class_name: 'MatchLog', inverse_of: :match, dependent: :destroy
  has_many :players, through: :logs

  PERMITTED_ATTRIBUTES = %i[
    home
    away
    competition
    extra_time
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

  def home_score
    @home_score ||= home_score_override ||
                    goals.count { |goal| goal.home? ^ goal.own_goal? }
  end

  def away_score
    @away_score ||= away_score_override ||
                    goals.count { |goal| goal.away? ^ goal.own_goal? }
  end

  def team_played?
    [ home, away ].include? team.title
  end

  def team_result
    if team_played?
      if home_score > away_score
        'win'
      elsif home_score == away_score
        'draw'
      else
        'loss'
      end
    else
      nil
    end
  end

  def score
    score = home_score.to_s
    score += " (#{ penalty_shootout.home_score })" if penalty_shootout
    score += ' - '
    score += away_score.to_s
    score += " (#{ penalty_shootout.away_score })" if penalty_shootout
    score
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ score team_result ]
    }))
  end

end
