# == Schema Information
#
# Table name: penalty_shootouts
#
#  id         :integer          not null, primary key
#  match_id   :integer
#  home_score :integer
#  away_score :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_penalty_shootouts_on_match_id  (match_id)
#

require 'rails_helper'

RSpec.describe PenaltyShootout, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
