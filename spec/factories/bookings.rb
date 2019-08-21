# frozen_string_literal: true

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

FactoryBot.define do
  factory :booking do
    minute { Faker::Number.between(from: 1, to: 120) }
    player
    match
  end
end
