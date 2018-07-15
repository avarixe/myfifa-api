# == Schema Information
#
# Table name: matches
#
#  id                  :bigint(8)        not null, primary key
#  team_id             :bigint(8)
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
  belongs_to :team
  has_one :penalty_shootout, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :substitutions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  has_many :match_logs, dependent: :destroy
  has_many :players, through: :match_logs

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

  def team_home?
    team.title == home
  end

  def team_result
    if team_played?
      team_score = team_home? ? home_score : away_score
      other_score = team_home? ? away_score : home_score

      if team_score > other_score
        'win'
      elsif team_score == other_score
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

  def events
    [ *goals, *substitutions, *bookings ]
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ score team_result events ],
      include: {
        match_logs: { methods: %i[ name ] }
      }
    }))
  end

end
