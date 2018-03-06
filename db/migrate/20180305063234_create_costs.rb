class CreateCosts < ActiveRecord::Migration[5.1]
  def change
    create_table :costs do |t|
      t.belongs_to :contract
      t.string :type
      t.integer :fee
      t.integer :traded_player_id
      t.integer :addon_clause

      t.timestamps
    end
  end
end
