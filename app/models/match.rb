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
  validate :different_teams

  def different_teams
    errors.add(:away, 'must differ from Home') if home == away
  end

  ##############
  #  CALLBACK  #
  ##############

  before_validation :set_defaults

  def set_defaults
    self.date_played ||= team.current_date
  end

  ##############
  #  MUTATORS  #
  ##############

  def apply(squad)
    MatchLog.transaction do
      # Remove existing Match Logs
      match_logs.clear

      # Add new Match Logs from Squad player list
      squad.players_list.each_with_index do |player_id, i|
        match_logs.create player_id: player_id,
                          pos: squad.positions_list[i]
      end
    end

    # Reload association to include new MatchLogs
    match_logs.reload
  end

  def reset_score
    @home_score = nil
    @away_score = nil
  end

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
    [home, away].include? team.title
  end

  def team_home?
    team.title == home
  end

  def team_result
    return unless team_played?
    team_score = team_home? ? home_score : away_score
    other_score = team_home? ? away_score : home_score

    if team_score > other_score
      'win'
    elsif team_score == other_score
      'draw'
    else
      'loss'
    end
  end

  def score
    score = home_score.to_s
    score += " (#{penalty_shootout.home_score})" if penalty_shootout
    score += ' - '
    score += away_score.to_s
    score += " (#{penalty_shootout.away_score})" if penalty_shootout
    score
  end

  def winner
    if home_score > away_score
      home
    elsif home_score < away_score
      away
    elsif penalty_shootout.present?
      penalty_shootout.winner
    end
  end

  def events
    [*goals, *substitutions, *bookings].sort_by(&:minute)
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[
      home_score
      away_score
      score
      team_result
      penalty_shootout
    ]
    super
  end

  def full_json
    as_json methods: %i[events match_logs]
  end
end
