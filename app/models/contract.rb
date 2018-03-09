# == Schema Information
#
# Table name: contracts
#
#  id                :integer          not null, primary key
#  player_id         :integer
#  signed_date       :date
#  start_date        :date
#  end_date          :date
#  origin            :string
#  destination       :string
#  loan              :boolean          default(FALSE)
#  youth             :boolean          default(FALSE)
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_contracts_on_player_id  (player_id)
#

class Contract < ApplicationRecord
  belongs_to :player
  has_many :contract_histories, dependent: :destroy
  has_many :costs, dependent: :destroy

  BONUS_REQUIREMENT_TYPES = [
    'Appearances',
    'Goals',
    'Assists',
    'Clean Sheets'
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    signed_date
    start_date
    end_date
    origin
    destination
    loan
    youth
    wage
    signing_bonus
    release_clause
    performance_bonus
    bonus_req
    bonus_req_type
  ].freeze

  def self.permitted_create_attributes
    PERMITTED_ATTRIBUTES
  end

  def self.permitted_update_attributes
    PERMITTED_ATTRIBUTES.drop 1
  end

  ################
  #  VALIDATION  #
  ################

  validates :signed_date, presence: true
  validates :start_date,
            date: {
              after_or_equal_to: :signed_date,
              before_or_equal_to: :end_date
            }
  validates :end_date, presence: true
  validates :wage, numericality: { only_integer: true }
  validates :bonus_req_type,
            inclusion: { in: BONUS_REQUIREMENT_TYPES },
            allow_nil: true
  validates :costs, length: { maximum: 2 }
  validate  :valid_performance_bonus
  validate  :valid_youth?, if: proc { |c| c.youth? }
  validate  :valid_loan?, if: proc { |c| c.loan? }

  def valid_performance_bonus
    return unless [performance_bonus, bonus_req, bonus_req_type].any? &&
                  ![performance_bonus, bonus_req, bonus_req_type].all?
    errors.add(:performance_bonus, 'requires all three fields')
  end

  def valid_youth?
    errors.add(:origin, 'must be blank for Youth') if origin.present?
    errors.add(:loan, 'can not be Youth') if loan?
  end

  def valid_loan?
    return if origin == destination
    errors.add(:destination, 'must be same as Origin for Loaned Players')
  end

  ##############
  #  CALLBACK  #
  ##############

  after_create :set_player_status
  after_save :save_history

  def set_player_status
    player.update(status: 'active') if team.current_date >= start_date
  end

  def save_history
    contract_histories.create(
      datestamp:         team.current_date,
      end_date:          end_date,
      wage:              wage,
      signing_bonus:     signing_bonus,
      release_clause:    release_clause,
      performance_bonus: performance_bonus,
      bonus_req:         bonus_req,
      bonus_req_type:    bonus_req_type,
    )
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def pending?
    team.current_date < start_date
  end

  def active?
    start_date <= team.current_date && team.current_date <= end_date
  end

  def expired?
    end_date < team.current_date
  end
end
