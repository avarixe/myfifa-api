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

require 'rails_helper'

RSpec.describe PlayerHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
