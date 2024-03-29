# frozen_string_literal: true

# == Schema Information
#
# Table name: matches
#
#  id              :bigint           not null, primary key
#  away            :string
#  away_possession :integer          default(50)
#  away_score      :integer          default(0)
#  away_xg         :float
#  competition     :string
#  extra_time      :boolean          default(FALSE), not null
#  friendly        :boolean          default(FALSE), not null
#  home            :string
#  home_possession :integer          default(50)
#  home_score      :integer          default(0)
#  home_xg         :float
#  played_on       :date
#  season          :integer
#  stage           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  team_id         :bigint
#
# Indexes
#
#  index_matches_on_team_id  (team_id)
#

class Match < ApplicationRecord
  include Broadcastable

  belongs_to :team
  has_one :penalty_shootout, dependent: :destroy
  has_many :goals,
           -> { order :minute },
           inverse_of: :match,
           dependent: :destroy
  has_many :bookings,
           -> { order :minute },
           inverse_of: :match,
           dependent: :destroy

  has_many :caps,
           -> { order :start },
           inverse_of: :match,
           dependent: :destroy
  has_many :players, through: :caps

  accepts_nested_attributes_for :penalty_shootout,
                                allow_destroy: true,
                                update_only: true

  cache_options 'Team', :home, :away

  ################
  #  VALIDATION  #
  ################

  validates :home, presence: true
  validates :away, presence: true
  validates :competition, presence: true, unless: :friendly?
  validates :played_on, presence: true
  validates :home_xg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :away_xg, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :home_possession, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :away_possession, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validate :different_teams

  def different_teams
    errors.add(:away, 'must differ from Home') if home == away
  end

  ##############
  #  CALLBACK  #
  ##############

  before_create :set_season
  after_save :increment_currently_on, if: lambda {
    saved_change_to_played_on? && team.currently_on < played_on
  }
  after_save :set_cap_stop_times, if: :saved_change_to_extra_time?

  def set_season
    self.season = ((played_on - team.started_on) / 365).to_i
  end

  def increment_currently_on
    team.update(currently_on: played_on)
  end

  def set_cap_stop_times
    caps.where(next_id: nil).find_each do |cap|
      cap.update(stop: extra_time? ? 120 : 90)
    end
  end

  ##############
  #  MUTATORS  #
  ##############

  def apply(squad)
    self.caps = squad.eligible_players.map do |squad_player|
      Cap.new(player_id: squad_player.player_id, pos: squad_player.pos)
    end
  end

  ###############
  #  ACCESSORS  #
  ###############

  def team_played? = [home, away].include? team.name

  def team_home? = team.name == home

  def team_score = team_home? ? home_score : away_score

  def other_score = team_home? ? away_score : home_score

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

  def num_minutes
    extra_time? ? 120 : 90
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[
      score
      team_result
    ]
    super
  end
end
