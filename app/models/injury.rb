# == Schema Information
#
# Table name: injuries
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  start_date  :date
#  end_date    :date
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

class Injury < ApplicationRecord
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    start_date
    end_date
    description
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  #################
  #  VALIDATIONS  #
  #################

  validates :start_date, presence: true
  validates :end_date, date: { after_or_equal_to: :start_date }, allow_nil: true
  validate :no_double_injury, on: :create

  def no_double_injury
    return unless player.injured?
    errors.add(:base, 'Player can not be injured when already injured.')
  end

  ###############
  #  CALLBACKS  #
  ###############

  after_initialize :set_start_date
  after_save :set_player_status

  def set_start_date
    self.start_date = team.current_date
  end

  def set_player_status
    player.update(status: (end_date ? 'Active' : 'Injured'))
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player
end
