# == Schema Information
#
# Table name: contract_histories
#
#  id                :integer          not null, primary key
#  contract_id       :integer
#  datestamp         :date
#  wage              :integer
#  signing_bonus     :integer
#  release_clause    :integer
#  performance_bonus :integer
#  bonus_req         :integer
#  bonus_req_type    :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  end_date          :date
#  effective_date    :date
#
# Indexes
#
#  index_contract_histories_on_contract_id  (contract_id)
#

class ContractHistory < ApplicationRecord
  belongs_to :contract

  validates :datestamp, presence: true
  validates :wage, numericality: { only_integer: true }
  validates :bonus_req_type,
            inclusion: { in: Contract::BONUS_REQUIREMENT_TYPES },
            allow_nil: true
  validate  :valid_performance_bonus

  def valid_performance_bonus
    return if [performance_bonus, bonus_req, bonus_req_type].all? ||
              [performance_bonus, bonus_req, bonus_req_type].none?
    puts 'not valid performance bonus in history'
    errors.add(:performance_bonus, 'requires all three fields')
  end

  delegate :current_date, to: :contract

  after_initialize :set_datestamp

  def set_datestamp
    self.datestamp ||= current_date
  end
end
