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

class MatchLog < ApplicationRecord
  belongs_to :match
  belongs_to :player

  validates :start, inclusion: 0..120
  validates :stop, inclusion: 0..120
end
