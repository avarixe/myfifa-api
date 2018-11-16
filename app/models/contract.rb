# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint(8)        not null, primary key
#  player_id         :bigint(8)
#  signed_date       :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  end_date          :date
#  effective_date    :date
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
    end_date
    effective_date
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :active, lambda { |player|
    where('effective_date >= ?', player.current_date)
      .where('? <= end_date', player.current_date)
  }

  ################
  #  VALIDATION  #
  ################

  validates :signed_date, presence: true
  validates :effective_date,
            date: {
              after_or_equal_to: :signed_date,
              before_or_equal_to: :end_date
            }
  validates :end_date, presence: true
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

  before_validation :set_signed_date
  after_create :update_status

  def set_signed_date
    self.signed_date ||= team.current_date
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def terminate!
    update(end_date: current_date)
  end

  def retire!
    update(end_date: team.end_of_season + 1.day)
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, :current_date, :youth?, :loaned?, to: :player

  def current?
    pending? || active?
  end

  def active?
    effective_date <= current_date && current_date < end_date
  end

  def pending?
    signed_date <= current_date && current_date < effective_date
  end
end
