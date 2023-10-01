# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  home        :boolean          default(FALSE), not null
#  minute      :integer
#  player_name :string
#  red_card    :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cap_id      :bigint
#  match_id    :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_bookings_on_cap_id     (cap_id)
#  index_bookings_on_match_id   (match_id)
#  index_bookings_on_player_id  (player_id)
#

class Booking < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player, optional: true
  belongs_to :cap, optional: true

  validates :minute, inclusion: 1..120
  validates :player_name, presence: true

  before_validation :set_player, if: -> { cap_id.present? }

  def set_player
    self.player_id = cap.player_id
    self.player_name = player.name
  end

  delegate :team, to: :match
end
