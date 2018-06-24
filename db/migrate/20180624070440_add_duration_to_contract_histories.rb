class AddDurationToContractHistories < ActiveRecord::Migration[5.1]
  def change
    add_column :contract_histories, :duration, :integer
    remove_column :contract_histories, :end_date, :integer
  end
end
