class AddScoreOverridesToMatch < ActiveRecord::Migration[5.1]
  def change
    add_column :matches, :home_score_override, :integer
    add_column :matches, :away_score_override, :integer
  end
end
