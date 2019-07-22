class CreateFixtureLegs < ActiveRecord::Migration[5.2]
  def change
    create_table :fixture_legs do |t|
      t.belongs_to :fixture
      t.string :home_score
      t.string :away_score

      t.timestamps
    end
  end
end
