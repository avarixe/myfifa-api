# frozen_string_literal: true

# == Schema Information
#
# Table name: players
#
#  id          :bigint(8)        not null, primary key
#  team_id     :bigint(8)
#  name        :string
#  nationality :string
#  pos         :string
#  sec_pos     :text             default([]), is an Array
#  ovr         :integer
#  value       :integer
#  birth_year  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  status      :string
#  youth       :boolean          default(TRUE)
#  kit_no      :integer
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

  has_many :performances, dependent: :destroy
  has_many :matches, through: :performances

  has_many :goals, dependent: :destroy
  has_many :assists,
           class_name: 'Goal',
           foreign_key: :assist_id,
           inverse_of: :assisting_player,
           dependent: :destroy
  has_many :bookings, dependent: :destroy

  STATUSES = %w[
    Pending
    Active
    Injured
    Loaned
  ].freeze

  POSITIONS = %w[
    GK
    RB
    RWB
    CB
    LB
    LWB
    RM
    CDM
    CM
    CAM
    LM
    RW
    CF
    ST
    LW
  ].freeze

  PERMITTED_ATTRIBUTES = %i[
    name
    pos
    ovr
    value
    kit_no
    birth_year
    youth
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  ################
  #  VALIDATION  #
  ################

  validates :name, presence: true
  validates :birth_year, numericality: { greater_than: 0, only_integer: true }
  validates :ovr, inclusion: 0..100
  validates :value, numericality: { greater_than: 0, only_integer: true }
  validates :kit_no, numericality: { only_integer: true }, allow_nil: true
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

  before_save :set_kit_no, if: :status_changed?
  after_create :save_history
  after_update :update_history
  after_update :end_pending_injuries, unless: :injured?

  def set_kit_no
    self.kit_no = nil if status.blank? || loaned?
  end

  def save_history
    player_histories.create ovr: ovr,
                            value: value,
                            kit_no: kit_no
  end

  def update_history
    if saved_change_to_ovr? ||
       saved_change_to_value? ||
       saved_change_to_kit_no?
      save_history
    end
  end

  def end_pending_injuries
    injuries.where(end_date: nil).update(end_date: current_date)
  end

  ##############
  #  MUTATORS  #
  ##############

  def update_status
    update status:
      if current_contract.nil?        then nil
      elsif current_loan              then 'Loaned'
      elsif current_injury            then 'Injured'
      elsif current_contract.pending? then 'Pending'
      else 'Active'
      end
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :current_date, to: :team

  %w[active pending injured loaned].each do |condition|
    define_method "#{condition}?" do
      status == condition.capitalize
    end
  end

  %w[contract injury loan transfer].each do |record|
    define_method "current_#{record}" do
      last_record = public_send(record.pluralize).last
      last_record if last_record&.current?
    end
  end

  def age
    current_date.year - birth_year
  end

  def pos_idx
    POSITIONS.index pos
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[age pos_idx current_contract]
    super
  end
end
