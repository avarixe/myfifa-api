class AddExtraTimeToMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :extra_time, :boolean, default: false
  end
end
