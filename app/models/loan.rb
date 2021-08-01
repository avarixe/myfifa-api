# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id              :bigint           not null, primary key
#  addon_clause    :integer
#  destination     :string
#  ended_on        :date
#  origin          :string
#  signed_on       :date
#  started_on      :date
#  transfer_fee    :integer
#  wage_percentage :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  player_id       :bigint
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

class Loan < ApplicationRecord
  include Broadcastable

  belongs_to :player

  scope :active_for, lambda { |team|
    joins(:player)
      .where(players: { team_id: team.id })
      .where(started_on: nil..team.currently_on)
      .where('ended_on IS NULL OR ended_on > ?', team.currently_on)
  }

  ################
  #  VALIDATION  #
  ################

  validates :started_on, presence: true
  validates :origin, presence: true
  validates :destination, presence: true
  validates :ended_on,
            date: { after_or_equal_to: :started_on },
            allow_nil: true
  validates :wage_percentage, inclusion: { in: 0..100, allow_nil: true }

  ###############
  #  CALLBACKS  #
  ###############

  before_validation :set_signed_on
  after_update :end_current_contract, if: -> { loaned_in? && @returned }
  after_update :activate_buy_option, if: -> { @activated_buy_option }
  after_save :update_status

  def set_signed_on
    self.signed_on ||= team.currently_on
  end

  def end_current_contract
    player.contracts.last&.update(ended_on: ended_on)
    player.update_status
  end

  def activate_buy_option
    player.transfers.create origin: origin,
                            destination: destination,
                            fee: transfer_fee,
                            addon_clause: addon_clause,
                            moved_on: team.currently_on
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def returned=(val)
    @returned = val
    self.ended_on = team.currently_on if player_id && val
  end

  def activated_buy_option=(val)
    @activated_buy_option = val
    self.returned = val
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def current?
    started_on <= team.currently_on &&
      (ended_on.nil? || team.currently_on < ended_on)
  end

  def loaned_in?
    team.name == destination
  end

  def loaned_out?
    team.name == origin
  end
end
