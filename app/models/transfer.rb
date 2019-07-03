# frozen_string_literal: true

# == Schema Information
#
# Table name: transfers
#
#  id            :bigint(8)        not null, primary key
#  player_id     :bigint(8)
#  signed_on     :date
#  moved_on      :date
#  origin        :string
#  destination   :string
#  fee           :integer
#  traded_player :string
#  addon_clause  :integer
#  loan          :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

class Transfer < ApplicationRecord
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    signed_on
    moved_on
    origin
    destination
    fee
    traded_player
    addon_clause
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  ################
  #  VALIDATION  #
  ################

  validates :origin, presence: true
  validates :destination, presence: true
  validates :moved_on, presence: true
  validates :addon_clause,
            inclusion: { in: 0..100 },
            allow_nil: true

  ###############
  #  CALLBACKS  #
  ###############

  before_validation :set_signed_on
  after_create :end_current_contract, if: :out?

  def set_signed_on
    self.signed_on ||= team.currently_on
  end

  def end_current_contract
    return if player.contracts.none?

    player.contracts.last.update(ended_on: moved_on)
    player.update_status
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def out?
    team.title == origin
  end
end
