# == Schema Information
#
# Table name: contracts
#
#  id                :integer          not null, primary key
#  player_id         :integer
#  signed_date       :date
#  start             :date
#  end               :date
#  origin            :string
#  destination       :string
#  loan              :boolean          default(FALSE)
#  youth             :boolean          default(FALSE)
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
#  index_contracts_on_player_id  (player_id)
#

class Contract < ApplicationRecord
  belongs_to :player
  has_many :contract_histories
  has_one :arrival_cost, -> { where type: 'Arrival' }, class_name: 'Cost'
  has_one :departure_cost, -> { where type: 'Departure' }, class_name: 'Cost'
end
