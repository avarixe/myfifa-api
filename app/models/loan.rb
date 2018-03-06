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

class Loan < ApplicationRecord
  belongs_to :player
end
