# == Schema Information
#
# Table name: squads
#
#  id             :integer          not null, primary key
#  team_id        :integer
#  name           :string
#  players_list   :text             default([]), is an Array
#  positions_list :text             default([]), is an Array
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_squads_on_team_id  (team_id)
#

FactoryBot.define do
  factory :squad do
    
  end
end
