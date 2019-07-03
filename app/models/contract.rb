# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint(8)        not null, primary key
#  player_id         :bigint(8)
#  signed_on         :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  ended_on          :date
#  started_on        :date
#
# Indexes
#
#  index_contracts_on_player_id  (player_id)
#

class Contract < ApplicationRecord
  belongs_to :player

  BONUS_REQUIREMENT_TYPES = [
    'Appearances',
    'Goals',
    'Assists',
    'Clean Sheets'
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    wage
    signing_bonus
    release_clause
    performance_bonus
    bonus_req
    bonus_req_type
    ended_on
    started_on
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :active, lambda { |player|
    where('started_on >= ?', player.currently_on)
      .where('? <= ended_on', player.currently_on)
  }

  ################
  #  VALIDATION  #
  ################

  validates :signed_on, presence: true
  validates :started_on,
            date: {
              after_or_equal_to: :signed_on,
              before_or_equal_to: :ended_on
            }
  validates :ended_on, presence: true
  validates :wage, numericality: { only_integer: true }
  validates :bonus_req_type,
            inclusion: { in: BONUS_REQUIREMENT_TYPES },
            allow_nil: true
  validate  :valid_performance_bonus

  def valid_performance_bonus
    return if [performance_bonus, bonus_req, bonus_req_type].all? ||
              [performance_bonus, bonus_req, bonus_req_type].none?

    errors.add(:performance_bonus, 'requires all three fields')
  end

  ##############
  #  CALLBACK  #
  ##############

  before_validation :set_signed_on
  after_create :close_previous_contract
  after_create :update_status

  def set_signed_on
    self.signed_on ||= currently_on
  end

  def close_previous_contract
    Contract
      .where(player_id: player_id)
      .where('ended_on > ?', started_on)
      .where.not(id: id)
      .each do |contract|
        contract.update!(ended_on: started_on)
      end
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def terminate!
    update(ended_on: currently_on)
  end

  def retire!
    update(ended_on: team.end_of_season + 1.day)
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, :currently_on, :youth?, :loaned?, to: :player

  def current?
    pending? || active?
  end

  def active?
    started_on <= currently_on && currently_on < ended_on
  end

  def pending?
    signed_on <= currently_on && currently_on < started_on
  end
end
