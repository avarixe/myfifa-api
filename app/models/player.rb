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
#
# Indexes
#
#  index_players_on_team_id  (team_id)
#

class Player < ApplicationRecord
  belongs_to :team
  has_many :player_histories
  has_many :injuries
  has_many :loans
  has_many :contracts
  validates_associated :contracts

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

  serialize :sec_pos, Array

  validates :name, presence: true
  validates :nationality, presence: true
  validates :age, numericality: { only_integer: true }
  validates :ovr, numericality: { only_integer: true }
  validates :value, numericality: { only_integer: true }
  validates :pos, inclusion: { in: POSITIONS }
  validate :valid_sec_pos

  def valid_sec_pos
    return if sec_pos.nil?
    sec_pos.each do |pos|
      next if POSITIONS.include?(pos)
      errors.add(:sec_pos, "#{pos} is not a valid Position")
    end
  end

end
