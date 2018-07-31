# == Schema Information
#
# Table name: bookings
#
#  id          :bigint(8)        not null, primary key
#  match_id    :bigint(8)
#  minute      :integer
#  player_id   :bigint(8)
#  red_card    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  player_name :string
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
    player_name
    player_id
    red_card
  ].freeze

  def self.permitted_attributes
    PERMITTED_ATTRIBUTES
  end

  validates :minute, inclusion: 1..120

  def home
    match.team_home?
  end

  def event_type
    'Booking'
  end

  def as_json(options = {})
    options[:methods] ||= []
    options[:methods] += %i[event_type home]
    super
  end
end
