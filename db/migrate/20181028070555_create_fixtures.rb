class CreateFixtures < ActiveRecord::Migration[5.2]
  def change
    create_table :fixtures do |t|
      t.belongs_to :stage

      t.string :home_team
      t.string :away_team
      t.string :home_score
      t.string :away_score

      t.timestamps
    end
  end
end
