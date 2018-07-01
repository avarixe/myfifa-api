# == Schema Information
#
# Table name: contracts
#
#  id                :integer          not null, primary key
#  player_id         :integer
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
  has_many :contract_histories, dependent: :destroy
  # has_many :costs, dependent: :destroy

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

  scope :active, -> { where(end_date: nil) }

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
  validates :duration, numericality: { only_integer: true }
  validate  :valid_performance_bonus

  def valid_performance_bonus
    return unless [performance_bonus, bonus_req, bonus_req_type].any? &&
                  ![performance_bonus, bonus_req, bonus_req_type].all?
    errors.add(:performance_bonus, 'requires all three fields')
  end

  ##############
  #  CALLBACK  #
  ##############

  after_initialize :set_signed_date
  after_save :save_history
  after_create :set_player_status

  def set_signed_date
    self.signed_date ||= team.current_date
  end

  def save_history
    contract_histories.create(
      datestamp:         team.current_date,
      wage:              wage,
      signing_bonus:     signing_bonus,
      release_clause:    release_clause,
      performance_bonus: performance_bonus,
      bonus_req:         bonus_req,
      bonus_req_type:    bonus_req_type,
      effective_date:    effective_date,
      end_date:          end_date
    )
  end

  def set_player_status
    player.update(status: 'Active') if team.current_date >= effective_date
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player
  delegate :youth?, to: :player
  delegate :loaned?, to: :player

  def active?
    effective_date <= team.current_date && team.current_date <= end_date
  end

  def expired?
    end_date < team.current_date
  end
end
