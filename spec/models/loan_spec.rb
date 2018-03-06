# == Schema Information
#
# Table name: loans
#
#  id          :integer          not null, primary key
#  player_id   :integer
#  start       :date
#  end         :date
#  destination :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_loans_on_player_id  (player_id)
#

require 'rails_helper'

RSpec.describe Loan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
