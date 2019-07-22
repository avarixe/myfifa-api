# frozen_string_literal: true

# == Schema Information
#
# Table name: matches
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  home        :string
#  away        :string
#  competition :string
#  played_on   :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  extra_time  :boolean          default(FALSE)
#  home_score  :integer
#  away_score  :integer
#  stage       :string
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

class Match < ApplicationRecord
  include Broadcastable

  belongs_to :team
  has_one :penalty_shootout, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :substitutions, dependent: :destroy
  has_many :bookings, dependent: :destroy

  has_many :caps, dependent: :destroy
  has_many :players, through: :caps

  PERMITTED_ATTRIBUTES = %i[
    home
    away
    played_on
    competition
    stage
    extra_time
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :with_players, -> { includes(caps: :player) }

  ################
  #  VALIDATION  #
  ################

  validates :home, presence: true
  validates :away, presence: true
  validates :competition, presence: true
  validates :played_on, presence: true
  validate :different_teams

  def different_teams
    errors.add(:away, 'must differ from Home') if home == away
  end

  ##############
  #  CALLBACK  #
  ##############

  before_validation :set_defaults
  after_save :increment_currently_on, if: :saved_change_to_played_on?
  after_save :set_cap_stop_times, if: :saved_change_to_extra_time?

  def set_defaults
    self.played_on ||= currently_on
    self.home_score ||= 0
    self.away_score ||= 0
  end

  def increment_currently_on
    return if currently_on >= played_on

    team.update(currently_on: played_on)
  end

  def set_cap_stop_times
    caps
      .where(subbed_out: false)
      .update_all(stop: extra_time? ? 120 : 90)
  end

  ##############
  #  MUTATORS  #
  ##############

  def apply(squad)
    Cap.transaction do
      # Remove existing Caps
      caps.map(&:destroy)

      # Add new Caps from Squad Players
      squad.squad_players.each do |item|
        caps.create player_id: item.player_id, pos: item.pos
      end
    end

    # Reload association to include new Caps
    caps.reload
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :currently_on, to: :team

  def team_played?
    [home, away].include? team.title
  end

  def team_home?
    team.title == home
  end

  def team_score
    team_home? ? home_score : away_score
  end

  def other_score
    team_home? ? away_score : home_score
  end

  def team_result
    return unless team_played?

    if team_score > other_score     then 'win'
    elsif team_score == other_score then 'draw'
    else 'loss'
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

  def events
    [*goals, *substitutions, *bookings].sort_by(&:minute)
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[
      score
      team_score
      other_score
      team_result
      penalty_shootout
    ]
    super
  end
end
