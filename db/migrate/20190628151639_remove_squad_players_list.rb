class RemoveSquadPlayersList < ActiveRecord::Migration[5.2]
  def up
    Squad.all.each do |squad|
      squad.players_list.each_with_index do |player_id, i|
        squad.squad_players.create(
          player_id: player_id,
          pos: squad.positions_list[i]
        )
      end
    end

    remove_column :squads, :players_list
    remove_column :squads, :positions_list
  end

  def down
    add_column :squads, :players_list, :text, array: true, default: []
    add_column :squads, :positions_list, :text, array: true, default: []

    Squad.includes(:squad_players).all.each do |squad|
      squad.squad_players.each do |squad_player|
        squad.players_list << squad_player.player_id
        squad.positions_list << squad_player.pos
      end
      squad.save!
    end
  end
end
