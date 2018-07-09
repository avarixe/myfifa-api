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

require 'rails_helper'

RSpec.describe Booking, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
