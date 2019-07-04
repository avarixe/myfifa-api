class CreateSquadPlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :squad_players do |t|
      t.belongs_to :squad
      t.belongs_to :player
      t.string :pos

      t.timestamps
    end
  end
end
