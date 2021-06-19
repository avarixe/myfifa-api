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
#  match_id    :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_bookings_on_match_id   (match_id)
#  index_bookings_on_player_id  (player_id)
#

class Booking < ApplicationRecord
  include Broadcastable

  belongs_to :match
  belongs_to :player, optional: true

  PERMITTED_ATTRIBUTES = %i[
    minute
    player_name
    player_id
    red_card
    home
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120
  validates :player_name, presence: true

  before_validation :set_names
  before_create :set_default_bools

  def set_names
    self.player_name = player.name if player_id.present?
  end

  def set_default_bools
    self.red_card ||= false
    self.home ||= false
  end

  delegate :team, to: :match
end
