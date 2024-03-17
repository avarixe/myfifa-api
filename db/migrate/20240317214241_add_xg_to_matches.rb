class AddXgToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :home_xg, :float
    add_column :matches, :away_xg, :float
    add_column :matches, :home_possession, :integer, default: 50
    add_column :matches, :away_possession, :integer, default: 50
  end
end
