class AddTransferFeeToLoan < ActiveRecord::Migration[6.1]
  def change
    add_column :loans, :transfer_fee, :integer
    add_column :loans, :addon_clause, :integer
  end
end
