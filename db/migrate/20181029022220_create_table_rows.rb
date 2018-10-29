class CreateTableRows < ActiveRecord::Migration[5.2]
  def change
    create_table :table_rows do |t|
      t.belongs_to :stage

      t.string :name
      t.integer :wins
      t.integer :draws
      t.integer :losses
      t.integer :goals_for
      t.integer :goals_against

      t.timestamps
    end
  end
end
