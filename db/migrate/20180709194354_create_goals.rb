class CreateGoals < ActiveRecord::Migration[5.1]
  def change
    create_table :goals do |t|
      t.belongs_to :match
      t.integer :minute

      t.string :player_name
      t.belongs_to :player
      t.belongs_to :assist

      t.boolean :home, default: false
      t.boolean :own_goal, default: false
      t.boolean :penalty, default: false

      t.timestamps
    end
  end
end
