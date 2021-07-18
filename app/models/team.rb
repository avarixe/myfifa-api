# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint           not null, primary key
#  active       :boolean          default(TRUE), not null
#  currency     :string           default("$")
#  currently_on :date
#  name         :string
#  started_on   :date
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint
#
# Indexes
#
#  index_teams_on_user_id  (user_id)
#

class Team < ApplicationRecord
  include Broadcastable

  belongs_to :user
  has_many :players, dependent: :destroy
  has_many :squads, dependent: :destroy
  has_many :matches, dependent: :destroy
  has_many :competitions, dependent: :destroy

  has_one_attached :badge

  validates :name, presence: true
  validates :started_on, presence: true
  validates :currently_on, presence: true
  validates :currency, presence: true

  before_validation :set_started_on
  after_save :update_player_statuses, if: :saved_change_to_currently_on?

  def set_started_on
    self.currently_on ||= started_on
  end

  def team
    self
  end

  def update_player_statuses
    Player.transaction do
      players
        .preload(:contracts, :loans, :injuries)
        .find_each(&:update_status)
    end
  end

  def badge_path
    return unless badge.attached? && !destroyed?

    Rails.application.routes.url_helpers.rails_blob_url(badge, only_path: true)
  end

  def increment_date(amount)
    update(currently_on: currently_on + amount)
  end

  def current_season
    ((currently_on - started_on) / 365).to_i
  end

  def end_of_current_season
    end_of_season(current_season)
  end

  def end_of_season(season)
    started_on + (season + 1).years - 1.day
  end

  def opponents
    team.matches.pluck(:home, :away).flatten.uniq.sort
  end

  def competition_stats(competition: nil, season: nil)
    Statistics::CompetitionCompiler.new(
      team: self,
      competition: competition,
      season: season
    ).results
  end

  def player_stats(player_ids: [], competition: nil, season: nil)
    Statistics::PlayerCompiler.new(
      team: self,
      player_ids: player_ids,
      competition: competition,
      season: season
    ).results
  end

  def player_history_stats(player_ids: [], season: nil)
    Statistics::PlayerHistoryCompiler.new(
      team: self,
      player_ids: player_ids,
      season: season
    ).results
  end
end
