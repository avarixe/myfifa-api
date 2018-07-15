# == Schema Information
#
# Table name: injuries
#
#  id          :bigint(8)        not null, primary key
#  player_id   :bigint(8)
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

FactoryBot.define do
  factory :injury do
    start_date Faker::Date.backward(90)
    player
  end
end
