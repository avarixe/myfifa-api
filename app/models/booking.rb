# == Schema Information
#
# Table name: bookings
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  minute     :integer
#  player_id  :integer
#  red_card   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_bookings_on_match_id   (match_id)
#  index_bookings_on_player_id  (player_id)
#

class Booking < ApplicationRecord
  belongs_to :match
  belongs_to :player, optional: true

  PERMITTED_ATTRIBUTES = %i[
    minute
    player_id
    red_card
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120
end
