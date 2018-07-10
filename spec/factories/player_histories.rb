# == Schema Information
#
# Table name: player_histories
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  datestamp  :date
#  ovr        :integer
#  value      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kit_no     :integer
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

FactoryBot.define do
  factory :player_history do
    datestamp Faker::Date.backward(365)
    age Faker::Number.between(18, 40)
    ovr Faker::Number.between(50, 90)
    value Faker::Number.between(50_000, 200_000_000)
    player
  end
end
