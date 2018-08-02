class RenameMatchLogToPerformance < ActiveRecord::Migration[5.2]
  def change
    rename_table :match_logs, :performances
    
    Performance.where(rating: nil).update_all(rating: 3)
  end
end
