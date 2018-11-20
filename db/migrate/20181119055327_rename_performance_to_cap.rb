class RenamePerformanceToCap < ActiveRecord::Migration[5.2]
  def change
    rename_table :performances, :caps
  end
end
