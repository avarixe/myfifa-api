# == Schema Information
#
# Table name: transfers
#
#  id             :bigint(8)        not null, primary key
#  player_id      :bigint(8)
#  signed_date    :date
#  effective_date :date
#  origin         :string
#  destination    :string
#  fee            :integer
#  traded_player  :string
#  addon_clause   :integer
#  loan           :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transfers_on_player_id  (player_id)
#

FactoryBot.define do
  factory :transfer do
    origin { Faker::Team.unique.name }
    destination { Faker::Team.unique.name }
    player
  end
end
