# == Schema Information
#
# Table name: costs
#
#  id               :integer          not null, primary key
#  contract_id      :integer
#  type             :string
#  fee              :integer
#  traded_player_id :integer
#  addon_clause     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_costs_on_contract_id  (contract_id)
#

require 'rails_helper'

RSpec.describe Cost, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
