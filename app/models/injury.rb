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
    description
    recovered
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  scope :active, -> (player) { where(end_date: nil) }

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
  after_save :update_status

  def set_start_date
    self.start_date = team.current_date
  end

  ##############
  #  MUTATORS  #
  ##############

  delegate :update_status, to: :player

  def recovered=(val)
    if player_id
      write_attribute :end_date, team.current_date
    end
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

  def active?
    start_date <= team.current_date &&
    (end_date.nil? || team.current_date < end_date)
  end

  def recovered?
    end_date.present?
  end

  def recovered
    recovered?
  end

  def as_json(options = {})
    super((options || {}).merge({
      methods: %i[ recovered ]
    }))
  end
end
