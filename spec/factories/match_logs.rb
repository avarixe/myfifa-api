# == Schema Information
#
# Table name: match_logs
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  player_id  :integer
#  pos        :string
#  start      :integer
#  stop       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_match_logs_on_match_id   (match_id)
#  index_match_logs_on_player_id  (player_id)
#

FactoryBot.define do
  factory :match_log do
    
  end
end
