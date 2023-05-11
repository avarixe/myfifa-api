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
  has_many :players,
           -> { order :id },
           inverse_of: :team,
           dependent: :destroy
  has_many :squads,
           -> { order :id },
           inverse_of: :team,
           dependent: :destroy
  has_many :matches,
           -> { order played_on: :asc },
           inverse_of: :team,
           dependent: :destroy
  has_many :competitions,
           -> { order :id },
           inverse_of: :team,
           dependent: :destroy

  has_one_attached :badge

  cache_options 'Team', :name

  validates :name, presence: true
  validates :started_on, presence: true
  validates :currently_on, presence: true
  validates :currency, presence: true

  before_validation :set_started_on
  after_save :update_player_statuses, if: :saved_change_to_currently_on?

  def set_started_on
    self.currently_on ||= started_on
  end

  def update_player_statuses
    players.find_each do |player|
      player.update status:
        if pending_player_ids.include? player.id
          'Pending'
        elsif active_player_ids.exclude? player.id
          nil
        elsif loaned_player_ids.include? player.id
          'Loaned'
        elsif injured_player_ids.include? player.id
          'Injured'
        else
          'Active'
        end
    end
  end

  def increment_date(amount)
    update(currently_on: currently_on + amount)
  end

  def team = self

  def badge_path
    return unless badge.attached?

    Rails.application.routes.url_helpers.rails_blob_url badge, only_path: true
  end

  def current_season = ((currently_on - started_on) / 365).to_i

  def end_of_current_season = end_of_season(current_season)

  def end_of_season(season)
    started_on + (season + 1).years - 1.day
  end

  def opponents
    team.matches.pluck(:home, :away).flatten.uniq.sort
  end

  def last_match = matches.last

  def loaned_players = players.where(status: 'Loaned')

  def injured_players = players.where(status: 'Injured')

  def expiring_players
    players.joins(:contracts).where(
      contracts: {
        conclusion: nil,
        ended_on: nil..(end_of_current_season + 1.day)
      }
    )
  end

  def active_player_ids
    @active_player_ids ||=
      Contract.active_for(team: self, date: currently_on).pluck(:player_id)
  end

  def pending_player_ids
    @pending_player_ids ||=
      Contract.pending_for(team: self).pluck(:player_id)
  end

  def injured_player_ids
    @injured_player_ids ||= Injury.active_for(team: self).pluck(:player_id)
  end

  def loaned_player_ids
    @loaned_player_ids ||= Loan.active_for(team: self).pluck(:player_id)
  end
end
