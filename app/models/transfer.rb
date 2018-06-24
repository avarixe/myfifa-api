# == Schema Information
#
# Table name: transfers
#
#  id             :integer          not null, primary key
#  player_id      :integer
#  signed_date    :date
#  effective_date :date
#  origin         :string
#  destination    :string
#  fee            :integer
#  traded_player  :string
#  addon_clause   :integer
#  loan           :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

class Transfer < ApplicationRecord
  belongs_to :player

  PERMITTED_ATTRIBUTES = %i[
    signed_date
    effective_date
    origin
    destination
    fee
    traded_player
    loan
  ].freeze

  def self.permitted_create_attributes
    PERMITTED_ATTRIBUTES
  end

  def self.permitted_update_attributes
    PERMITTED_ATTRIBUTES
  end

  ################
  #  VALIDATION  #
  ################

  validates :addon_clause,
            inclusion: { in: 0..100 },
            allow_nil: true

  ###############
  #  CALLBACKS  #
  ###############

  after_initialize :set_signed_date

  def set_signed_date
    self.signed_date = team.current_date
  end

  ###############
  #  ACCESSORS  #
  ###############

  delegate :team, to: :player

end
