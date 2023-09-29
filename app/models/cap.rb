# frozen_string_literal: true

# == Schema Information
#
# Table name: caps
#
#  id         :bigint           not null, primary key
#  injured    :boolean          default(FALSE), not null
#  ovr        :integer
#  pos        :string
#  rating     :integer
#  start      :integer          default(0)
#  stop       :integer          default(90)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  match_id   :bigint
#  next_id    :bigint
#  player_id  :bigint
#
# Indexes
#
#  index_caps_on_match_id                          (match_id)
#  index_caps_on_next_id                           (next_id)
#  index_caps_on_player_id                         (player_id)
#  index_caps_on_player_id_and_match_id_and_start  (player_id,match_id,start) UNIQUE
#  index_caps_on_pos_and_match_id_and_start        (pos,match_id,start) UNIQUE
#

class Cap < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player
  has_one :previous,
          foreign_key: :next_id,
          class_name: 'Cap',
          inverse_of: :next,
          dependent: :nullify
  belongs_to :next,
             class_name: 'Cap',
             inverse_of: :previous,
             optional: true,
             dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :assists,
           foreign_key: :assist_cap_id,
           class_name: 'Goal',
           inverse_of: :assist_cap,
           dependent: :nullify

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
    LF
    CF
    RF
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
  validates :player_id, uniqueness: { scope: %i[match_id start] }
  validates :pos,
            inclusion: { in: POSITIONS },
            uniqueness: { scope: %i[match_id start] }
  validates :rating, inclusion: 1..5, allow_nil: true
  validates :ovr, inclusion: 0..100
  validate :same_team?
  validate :active_player?, if: :player_id

  def same_team?
    return false if match_id.nil? ||
                    player_id.nil? ||
                    match.team_id == player.team_id

    errors.add(:base, 'Player Team does not match Match Team')
  end

  def active_player?
    errors.add(:player, 'must be active') unless player.active?
  end

  before_validation :cache_ovr

  def cache_ovr
    self.ovr = PlayerHistory.order(recorded_on: :desc)
                            .find_by(player_id:, recorded_on: ..match.played_on)
                            &.ovr
  end

  delegate :team, to: :match
end
