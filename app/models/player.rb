# == Schema Information
#
# Table name: players
#
#  id          :integer          not null, primary key
#  team_id     :integer
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text
#  ovr         :integer
#  value       :integer
#  age         :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

class Player < ApplicationRecord
  belongs_to :team
  has_many :player_histories, dependent: :destroy
  has_many :injuries, dependent: :destroy
  has_many :loans, dependent: :destroy
  has_many :contracts, dependent: :destroy
  validates_associated :contracts

  STATUSES = %w[
    active
    injured
    loaned
  ].freeze

  POSITIONS = %w[
    GK
    CB
    LB
    LWB
    RB
    RWB
    CDM
    CM
    LM
    RM
    LW
    RW
    CAM
    CF
    ST
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    name
    nationality
    pos
    sec_pos
    ovr
    value
    age
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  serialize :sec_pos, Array

  ################
  #  VALIDATION  #
  ################

  validates :name, presence: true
  validates :nationality, presence: true
  validates :age, numericality: { only_integer: true }
  validates :ovr, numericality: { only_integer: true }
  validates :value, numericality: { only_integer: true }
  validates :pos, inclusion: { in: POSITIONS }
  validates :status, inclusion: { in: STATUSES }, allow_nil: true
  validate :valid_sec_pos

  def valid_sec_pos
    return if sec_pos.nil?
    sec_pos.each do |pos|
      next if POSITIONS.include?(pos)
      errors.add(:sec_pos, "#{pos} is not a valid Position")
    end
  end

  ##############
  #  CALLBACK  #
  ##############

  after_save :save_history

  def save_history
    return unless saved_change_to_age? ||
                  saved_change_to_ovr? ||
                  saved_change_to_value?
    player_histories.create(
      datestamp: team.current_date,
      age:       age,
      ovr:       ovr,
      value:     value,
    )
  end

  ###############
  #  ACCESSORS  #
  ###############

  def active?
    status == 'active'
  end

  def injured?
    status == 'injured'
  end

  def loaned?
    status == 'loaned'
  end
end
