# == Schema Information
#
# Table name: transfers
#
#  id             :integer          not null, primary key
#  player_id      :integer
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
    
  end
end
