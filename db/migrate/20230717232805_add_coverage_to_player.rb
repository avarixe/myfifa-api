class AddCoverageToPlayer < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :coverage, :jsonb, null: false, default: {}
    add_index :players, :coverage, using: :gin

    reversible do |dir|
      dir.up do
        Player.all.each do |player|
          coverage = {}
          [player.pos, *player.sec_pos].each_with_index do |pos, i|
            coverage_level = i.zero? ? 1 : 2
            coverage[pos] = coverage_level
          end
          player.update(coverage: coverage)
        end
      end
    end
  end
end
