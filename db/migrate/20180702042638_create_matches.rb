class CreateMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :matches do |t|
      t.belongs_to :team
      t.string :home
      t.string :away
      t.string :competition
      t.date :date_played

      t.timestamps
    end
  end
end
