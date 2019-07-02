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
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

class Loan < ApplicationRecord
  include Broadcastable

  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    destination
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
  validates :destination, presence: true
  validates :end_date,
            date: { after_or_equal_to: :start_date },
            allow_nil: true

  ###############
  #  CALLBACKS  #
  ###############

  before_validation :set_start_date
  after_save :update_status

  def set_start_date
    self.start_date ||= team.current_date
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

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] << :returned
    super
  end
end
