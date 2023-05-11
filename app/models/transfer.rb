# frozen_string_literal: true

# == Schema Information
#
# Table name: transfers
#
#  id            :bigint           not null, primary key
#  addon_clause  :integer
#  destination   :string
#  fee           :integer
#  moved_on      :date
#  origin        :string
#  signed_on     :date
#  traded_player :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  player_id     :bigint
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

class Transfer < ApplicationRecord
  include Broadcastable

  belongs_to :player

  cache_options 'Team', :origin, :destination

  ################
  #  VALIDATION  #
  ################

  validates :origin, presence: true
  validates :destination, presence: true
  validates :moved_on,
            date: { after_or_equal_to: :signed_on },
            if: :signed?
  validates :addon_clause,
            inclusion: { in: 0..100 },
            allow_nil: true

  ###############
  #  CALLBACKS  #
  ###############

  after_save :end_current_contract,
             if: -> { saved_change_to_signed_on? && signed? && out? }

  def end_current_contract
    player.contracts.last&.update ended_on: moved_on, conclusion: 'Transferred'
    player.update_status
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def signed? = signed_on.present?

  def out? = team.name == origin
end
