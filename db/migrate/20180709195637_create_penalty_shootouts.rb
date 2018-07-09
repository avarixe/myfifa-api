class CreatePenaltyShootouts < ActiveRecord::Migration[5.1]
  def change
    create_table :penalty_shootouts do |t|
      t.belongs_to :match

      t.integer :home_score
      t.integer :away_score

      t.timestamps
    end
  end
end
