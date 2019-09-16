# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id           :bigint(8)        not null, primary key
#  user_id      :bigint(8)
#  title        :string
#  started_on   :date
#  currently_on :date
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  currency     :string           default("$")
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

  PERMITTED_ATTRIBUTES = %i[
    started_on
    title
    currently_on
    currency
    badge
  ].freeze

  def self.permitted_create_attributes
    PERMITTED_ATTRIBUTES
  end

  def self.permitted_update_attributes
    PERMITTED_ATTRIBUTES.drop 1
  end

  validates :title, presence: true
  validates :started_on, presence: true
  validates :currently_on, presence: true
  validates :currency, presence: true

  before_validation :set_started_on
  after_save :update_player_statuses

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
        .map(&:update_status)
    end
  end

  def badge_path
    return unless badge.attached?

    Rails.application.routes.url_helpers.rails_blob_url(badge, only_path: true)
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[time_period badge_path]
    super
  end

  def increment_date(amount)
    update(currently_on: currently_on + amount)
  end

  def time_period
    "#{started_on.year} - #{currently_on.year}"
  end

  def current_season
    ((currently_on - started_on) / 365).to_i
  end

  def end_of_season
    started_on + (current_season + 1).years - 1.day
  end

  def season_data(season)
    season_start = started_on + season.years
    {
      label: "#{season_start.year} - #{season_start.year + 1}",
      start: season_start,
      end: season_start + 1.year - 1.day
    }
  end
end
