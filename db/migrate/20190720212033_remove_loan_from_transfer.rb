class RemoveLoanFromTransfer < ActiveRecord::Migration[5.2]
  def up
    remove_column :transfers, :loan
  end

  def down
    add_column :transfers, :loan, :boolean, default: false
  end
end
