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

class ContractHistory < ApplicationRecord
  belongs_to :contract
end
