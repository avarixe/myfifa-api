class AddKitNoToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :kit_no, :integer
    add_column :player_histories, :kit_no, :integer
  end
end
