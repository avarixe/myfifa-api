# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  match_id    :integer
#  minute      :integer
#  player_name :string
#  player_id   :integer
#  assist_id   :integer
#  home        :boolean          default(FALSE)
#  own_goal    :boolean          default(FALSE)
#  penalty     :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_goals_on_assist_id  (assist_id)
#  index_goals_on_match_id   (match_id)
#  index_goals_on_player_id  (player_id)
#

FactoryBot.define do
  factory :goal do
    
  end
end
