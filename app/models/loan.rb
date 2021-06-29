# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id              :bigint           not null, primary key
#  destination     :string
#  ended_on        :date
#  origin          :string
#  signed_on       :date
#  started_on      :date
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

  PERMITTED_ATTRIBUTES = %i[
    origin
    destination
    started_on
    wage_percentage
    returned
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :active, -> { where(ended_on: nil) }

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
  after_update :end_current_contract, if: :loaned_in?
  after_save :update_status

  def set_signed_on
    self.signed_on ||= team.currently_on
  end

  def end_current_contract
    return if !returned? && player.contracts.none?

    player.contracts.last.update(ended_on: ended_on)
    player.update_status
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def returned=(val)
    return unless player_id && val

    self.ended_on = team.currently_on
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def current?
    started_on <= team.currently_on &&
      (ended_on.nil? || team.currently_on < ended_on)
  end

  def returned?
    ended_on.present?
  end

  alias returned returned?

  def loaned_in?
    team.name == destination
  end

  def loaned_out?
    team.name == origin
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] << :returned
    super
  end
end
