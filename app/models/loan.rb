# == Schema Information
#
# Table name: loans
#
#  id          :integer          not null, primary key
#  player_id   :integer
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
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    end_date
    destination
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

  after_initialize :set_start_date
  after_create :end_pending_injuries
  after_save :set_player_status

  def set_start_date
    self.start_date = team.current_date
  end

  def end_pending_injuries
    player.injuries.where(end_date: nil).update(end_date: start_date)
  end

  def set_player_status
    player.update(status: (end_date ? 'Active' : 'Loaned'))
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player
end
