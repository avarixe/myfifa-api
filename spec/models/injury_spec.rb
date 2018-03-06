# == Schema Information
#
# Table name: injuries
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  start       :date
#  end         :date
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_injuries_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Injury, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
