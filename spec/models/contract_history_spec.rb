# == Schema Information
#
# Table name: contract_histories
#
#  id                :integer          not null, primary key
#  contract_id       :integer
#  datestamp         :date
#  end_date          :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_contract_histories_on_contract_id  (contract_id)
#

require 'rails_helper'

RSpec.describe ContractHistory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
