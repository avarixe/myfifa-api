# frozen_string_literal: true

# == Schema Information
#
# Table name: transfers
#
#  id            :bigint(8)        not null, primary key
#  player_id     :bigint(8)
#  signed_on     :date
#  moved_on      :date
#  origin        :string
#  destination   :string
#  fee           :integer
#  traded_player :string
#  addon_clause  :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

FactoryBot.define do
  factory :transfer do
    origin { Faker::Team.unique.name }
    destination { Faker::Team.unique.name }
    moved_on { Faker::Date.between(Date.today, 60.days.from_now) }
    player
  end
end
