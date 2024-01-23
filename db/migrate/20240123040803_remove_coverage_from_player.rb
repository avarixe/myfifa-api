class RemoveCoverageFromPlayer < ActiveRecord::Migration[7.0]
  def change
    remove_index :players, :coverage, using: :gin
    remove_column :players, :coverage, :jsonb, null: false, default: {}
  end
end
