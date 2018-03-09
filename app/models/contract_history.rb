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

  validates :datestamp, presence: true
  validates :end_date, presence: true
  validates :wage, numericality: { only_integer: true }
  validates :bonus_req_type,
            inclusion: { in: Contract::BONUS_REQUIREMENT_TYPES },
            allow_nil: true
  validate  :valid_performance_bonus

  def valid_performance_bonus
    if [performance_bonus, bonus_req, bonus_req_type].any? &&
       ![performance_bonus, bonus_req, bonus_req_type].all?
      errors.add(:performance_bonus, 'requires all three fields')
    end
  end
end
