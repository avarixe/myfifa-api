# frozen_string_literal: true

# == Schema Information
#
# Table name: contracts
#
#  id                :bigint           not null, primary key
#  bonus_req         :integer
#  bonus_req_type    :string
#  conclusion        :string
#  ended_on          :date
#  performance_bonus :integer
#  release_clause    :integer
#  signed_on         :date
#  signing_bonus     :integer
#  started_on        :date
#  wage              :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  player_id         :bigint
#  previous_id       :bigint
#
# Indexes
#
#  index_contracts_on_player_id    (player_id)
#  index_contracts_on_previous_id  (previous_id)
#

class Contract < ApplicationRecord
  include Broadcastable

  belongs_to :player
  belongs_to :previous,
             class_name: 'Contract',
             inverse_of: :renewal,
             optional: true
  has_one :renewal,
          class_name: 'Contract',
          foreign_key: :previous_id,
          inverse_of: :previous,
          dependent: :nullify

  scope :active_for, lambda { |team:, date:|
    joins(:player)
      .where(players: { team_id: team.id })
      .where.not(signed_on: nil)
      .where(started_on: nil..date)
      .where('ended_on > ?', date + 1.day)
  }

  scope :pending_for, lambda { |team:|
    joins(:player)
      .where(players: { team_id: team.id })
      .where(signed_on: nil..team.currently_on)
      .where('started_on > ?', team.currently_on)
  }

  BONUS_REQUIREMENT_TYPES = [
    'Appearances',
    'Goals',
    'Assists',
    'Clean Sheets'
  ].freeze

  CONCLUSION_TYPES = %w[
    Renewed
    Transferred
    Expired
    Released
    Retired
  ].freeze

  ################
  #  VALIDATION  #
  ################

  validates :started_on,
            date: { after_or_equal_to: :signed_on },
            if: :signed?
  validates :started_on, date: { before_or_equal_to: :ended_on }
  validates :ended_on, presence: true
  validates :wage, numericality: { only_integer: true }
  validates :bonus_req_type,
            inclusion: { in: BONUS_REQUIREMENT_TYPES },
            allow_nil: true
  validates :conclusion,
            inclusion: { in: CONCLUSION_TYPES },
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

  after_save :close_previous_contract,
             if: -> { saved_change_to_signed_on? && signed? }
  after_save :update_status,
             if: -> { saved_change_to_signed_on? && signed? }

  def close_previous_contract
    Contract
      .where(player_id: player_id)
      .where('ended_on > ?', started_on)
      .where.not(id: id)
      .find_each do |contract|
        contract.update! ended_on: started_on, conclusion: 'Renewed'
        update! previous_id: contract.id
      end
  end

  ##############
  #  MUTATORS  #
  ##############

  def terminate!
    update ended_on: team.currently_on,
           conclusion: 'Released'
  end

  def retire!
    update ended_on: team.end_of_current_season + 1.day,
           conclusion: 'Retired'
  end

  def num_seasons=(val)
    return if val.blank?

    num_years = ((started_on - team.started_on) / 365).round + val
    self.ended_on = team.started_on + num_years.years
    @num_seasons_set = true
  end

  def ended_on=(val)
    super unless @num_seasons_set
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, :update_status, to: :player

  def signed?
    signed_on.present?
  end

  def current?
    signed? && (pending? || active?)
  end

  def active?
    started_on <= team.currently_on && team.currently_on < ended_on
  end

  def pending?
    signed_on <= team.currently_on && team.currently_on < started_on
  end
end
