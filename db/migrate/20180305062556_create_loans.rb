class CreateLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :loans do |t|
      t.belongs_to :player
      t.date :start
      t.date :end
      t.string :destination

      t.timestamps
    end
  end
end
