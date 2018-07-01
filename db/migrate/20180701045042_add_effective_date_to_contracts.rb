class AddEffectiveDateToContracts < ActiveRecord::Migration[5.1]
  def change
    add_column :contracts, :effective_date, :date
    remove_column :contracts, :duration, :integer

    add_column :contract_histories, :end_date, :date
    add_column :contract_histories, :effective_date, :date
    remove_column :contract_histories, :duration, :integer
  end
end
