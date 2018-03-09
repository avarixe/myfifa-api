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

FactoryBot.define do
  factory :loan do
    start_date Faker::Date.backward(90)
    destination Faker::Team.name
    player
  end
end
