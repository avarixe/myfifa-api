# frozen_string_literal: true

# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  ovr        :integer
#  pos        :string
#  rating     :integer
#  start      :integer          default(0)
#  stop       :integer          default(90)
#  subbed_out :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id                    (match_id)
#  index_caps_on_player_id                   (player_id)
#  index_caps_on_player_id_and_match_id      (player_id,match_id) UNIQUE
#  index_caps_on_pos_and_match_id_and_start  (pos,match_id,start) UNIQUE
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
  validates :ovr, inclusion: 0..100
  validate :same_team?
  validate :active_player?, if: :player_id

  def same_team?
    return if match_id.nil? ||
              player_id.nil? ||
              match.team_id == player.team_id

    errors.add(:base, 'Player Team does not match Match Team')
  end

  def active_player?
    errors.add(:player, 'must be active') unless player.active?
  end

  before_validation :cache_ovr, if: :player_id_changed?
  after_destroy :remove_events

  def cache_ovr
    self.ovr = PlayerHistory.order(recorded_on: :desc)
                            .find_by(player_id:, recorded_on: ..match.played_on)
                            &.ovr
  end

  def remove_events
    goals.destroy_all
    assists.destroy_all
    bookings.destroy_all
    sub_outs.destroy_all
    sub_ins.destroy_all
  end

  def goals = Goal.where(match_id:, player_id:)

  def assists = Goal.where(match_id:, assist_id: player_id)

  def bookings = Booking.where(match_id:, player_id:)

  def sub_outs = Substitution.where(match_id:, player_id:)

  def sub_ins = Substitution.where(match_id:, replacement_id: player_id)

  delegate :team, to: :player
end
