class CreateSquads < ActiveRecord::Migration[5.1]
  def change
    create_table :squads do |t|
      t.belongs_to :team

      t.string :name
      t.text :players_list, array: true, default: []
      t.text :positions_list, array: true, default: []

      t.timestamps
    end
  end
end
