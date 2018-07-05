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
  has_many :events, class_name: 'MatchEvent'

  MatchEvent::EVENT_TYPES.drop(1).each do |event|
    has_many event.to_sym,
             class_name: "Event::#{event.singularize.titleize.tr(' ', '')}",
             inverse_of: :match
  end
  has_one :penalty_shootout,
          class_name: "Event::PenaltyShootout",
          inverse_of: :match

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
    player[:name].present? &&
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
    "#{home_score} - #{away_score}"
  end

  def home_score
    score = goals.home.count + own_goals.away.count
    if penalty_shootout
      score += " (#{penalty_shootout.home_score})"
    end
    score
  end

  def away_score
    score = goals.away.count + own_goals.home.count
    if penalty_shootout
      score += " (#{penalty_shootout.away_score})"
    end
    score
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ score ]
    }))
  end

end
