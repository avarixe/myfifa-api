class CreatePlayers < ActiveRecord::Migration[5.1]
  def change
    create_table :players do |t|
      t.belongs_to :team
      t.string :name
      t.string :nationality
      t.string :pos
      t.text :sec_pos
      t.integer :ovr
      t.integer :value
      t.integer :age

      t.timestamps
    end
  end
end
