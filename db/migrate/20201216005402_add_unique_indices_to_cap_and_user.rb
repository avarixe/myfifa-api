class AddUniqueIndicesToCapAndUser < ActiveRecord::Migration[6.1]
  def change
    add_index :caps, %i[player_id match_id], unique: true
    add_index :caps, %i[pos match_id start], unique: true
    add_index :users, :username, unique: true
  end
end
