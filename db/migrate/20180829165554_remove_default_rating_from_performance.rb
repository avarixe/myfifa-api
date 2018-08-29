class RemoveDefaultRatingFromPerformance < ActiveRecord::Migration[5.2]
  def up
    change_column_default :performances, :rating, nil
  end

  def down
    change_column :performances, :rating, :integer, default: 3
  end
end
