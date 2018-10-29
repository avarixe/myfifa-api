class CreateStages < ActiveRecord::Migration[5.2]
  def change
    create_table :stages do |t|
      t.belongs_to :competition

      t.string :name
      t.string :num_fixtures

      t.boolean :table, default: false

      t.timestamps
    end
  end
end
