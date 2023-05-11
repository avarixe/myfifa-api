class AddOvrToCap < ActiveRecord::Migration[7.0]
  def change
    add_column :caps, :ovr, :integer, if_not_exists: true

    reversible do |dir|
      dir.up do
        PlayerHistory.order(:recorded_on).each do |history|
          Cap
            .joins(:match)
            .where(player_id: history.player_id, matches: { played_on: history.recorded_on... })
            .update_all(ovr: history.ovr)
        end
      end
    end
  end
end
