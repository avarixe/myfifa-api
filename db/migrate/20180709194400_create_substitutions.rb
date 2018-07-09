class CreateSubstitutions < ActiveRecord::Migration[5.1]
  def change
    create_table :substitutions do |t|
      t.belongs_to :match
      t.integer :minute

      t.belongs_to :player
      t.belongs_to :replacement

      t.boolean :injury, default: false

      t.timestamps
    end
  end
end
