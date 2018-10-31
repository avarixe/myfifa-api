class CreateTableRows < ActiveRecord::Migration[5.2]
  def change
    create_table :table_rows do |t|
      t.belongs_to :stage

      t.string :name
      t.integer :wins, default: 0
      t.integer :draws, default: 0
      t.integer :losses, default: 0
      t.integer :goals_for, default: 0
      t.integer :goals_against, default: 0

      t.timestamps
    end
  end
end
