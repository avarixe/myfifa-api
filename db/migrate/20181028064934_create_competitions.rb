class CreateCompetitions < ActiveRecord::Migration[5.2]
  def change
    create_table :competitions do |t|
      t.belongs_to :team
      t.integer :season, index: true
      t.string :name
      t.string :champion

      t.timestamps
    end
  end
end
