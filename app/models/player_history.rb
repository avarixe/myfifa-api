# == Schema Information
#
# Table name: player_histories
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  datestamp  :date
#  ovr        :integer
#  value      :integer
#  age        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_player_histories_on_player_id  (player_id)
#

class PlayerHistory < ApplicationRecord
  belongs_to :player

  validates :age, numericality: { only_integer: true }
  validates :ovr, numericality: { only_integer: true }
  validates :value, numericality: { only_integer: true }
end
