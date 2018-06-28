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
#  youth       :boolean          default(TRUE)
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
  has_many :transfers, dependent: :destroy
  validates_associated :contracts

  STATUSES = %w[
    Active
    Injured
    Loaned
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
    ovr
    value
    age
    youth
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  serialize :sec_pos, Array

  ################
  #  VALIDATION  #
  ################

  validates :name, presence: true
  # validates :nationality, presence: true
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
    status == 'Active'
  end

  def injured?
    status == 'Injured'
  end

  def loaned?
    status == 'Loaned'
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[last_contract last_injury last_loan last_transfer]
    }))
  end

  %w[contract injury loan transfer].each do |record|
    define_method "last_#{record}" do
      public_send(record.pluralize).active.last
    end
  end
end
