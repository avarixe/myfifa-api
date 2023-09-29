class AddCapNext < ActiveRecord::Migration[7.0]
  def change
    add_reference :caps, :next
    remove_index :caps, %i[player_id match_id], unique: true
    add_index :caps, %i[player_id match_id start], unique: true
  end
end
