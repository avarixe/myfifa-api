# == Schema Information
#
# Table name: player_histories
#
#  id         :bigint(8)        not null, primary key
#  player_id  :bigint(8)
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
    datestamp Date.new
    ovr { Faker::Number.between(50, 90) }
    value { Faker::Number.between(50_000, 200_000_000) }
    kit_no { Faker::Number.between(1, 99) }
    player
  end
end
