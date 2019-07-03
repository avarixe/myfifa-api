# frozen_string_literal: true

# == Schema Information
#
# Table name: loans
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
#  start_date  :date
#  end_date    :date
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  origin      :string
#  signed_date :date
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

class Loan < ApplicationRecord
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    origin
    destination
    start_date
    returned
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :active, -> { where(end_date: nil) }

  ################
  #  VALIDATION  #
  ################

  validates :start_date, presence: true
  validates :origin, presence: true
  validates :destination, presence: true
  validates :end_date,
            date: { after_or_equal_to: :start_date },
            allow_nil: true

  ###############
  #  CALLBACKS  #
  ###############

  before_validation :set_signed_date
  after_save :update_status
  after_update :end_current_contract, if: :loaned_in?

  def set_signed_date
    self.signed_date ||= team.current_date
  end

  def end_current_contract
    return if !returned? && player.contracts.none?

    player.contracts.last.update(end_date: end_date)
    player.update_status
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def returned=(val)
    return unless player_id && val

    self.end_date = team.current_date
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def current?
    start_date <= team.current_date &&
      (end_date.nil? || team.current_date < end_date)
  end

  def returned?
    end_date.present?
  end

  def returned
    returned?
  end

  def loaned_in?
    team.title == destination
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] << :returned
    super
  end
end
