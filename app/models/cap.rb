# frozen_string_literal: true

# == Schema Information
#
# Table name: caps
#
#  id         :bigint(8)        not null, primary key
#  match_id   :bigint(8)
#  player_id  :bigint(8)
#  pos        :string
#  start      :integer
#  stop       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subbed_out :boolean          default(FALSE)
#  rating     :integer
#
# Indexes
#
#  index_caps_on_match_id   (match_id)
#  index_caps_on_player_id  (player_id)
#

class Cap < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player

  POSITIONS = %w[
    GK
    LB
    LWB
    LCB
    CB
    RCB
    RB
    RWB
    LM
    LDM
    LCM
    CDM
    CM
    RDM
    RCM
    RM
    LAM
    CAM
    RAM
    LW
    CF
    LS
    ST
    RS
    RW
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    player_id
    rating
    pos
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :clean_sheets, lambda { |team|
    left_outer_joins(:match)
      .where(
        '(home = ? AND away_score = 0) OR (away = ? AND home_score = 0)',
        team.title,
        team.title
      )
  }

  validates :start, inclusion: 0..120
  validates :stop,
            inclusion: 0..120,
            numericality: { greater_than_or_equal_to: :start },
            if: :start
  validates :player_id, uniqueness: { scope: :match_id }
  validates :pos,
            inclusion: { in: POSITIONS },
            uniqueness: { scope: %i[match_id start] }
  validates :rating, inclusion: 1..5, allow_nil: true
  validate :one_team?
  validate :active_player?, if: :player_id

  def one_team?
    return if match_id.nil? ||
              player_id.nil? ||
              match.team_id == player.team_id

    errors.add(:base, 'Player Team does not match Match Team')
  end

  def active_player?
    return if player.active?

    errors.add(:player, 'must be active')
  end

  after_initialize :set_defaults
  after_destroy :remove_events

  def set_defaults
    self.start ||= 0
    self.stop ||= 90
  end

  def remove_events
    [
      goals,
      assists,
      bookings,
      sub_outs,
      sub_ins
    ].map(&:delete_all)
  end

  def goals
    Goal.where(match_id: match_id, player_id: player_id)
  end

  def assists
    Goal.where(match_id: match_id, assist_id: player_id)
  end

  def bookings
    Booking.where(match_id: match_id, player_id: player_id)
  end

  def sub_outs
    Substitution.where(match_id: match_id, player_id: player_id)
  end

  def sub_ins
    Substitution.where(match_id: match_id, replacement_id: player_id)
  end

  delegate :team, :name, to: :player

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] << :name
    super
  end
end
