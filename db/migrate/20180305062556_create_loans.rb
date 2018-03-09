class CreateLoans < ActiveRecord::Migration[5.1]
  def change
    create_table :loans do |t|
      t.belongs_to :player
      t.date :start_date
      t.date :end_date
      t.string :destination

      t.timestamps
    end
  end
end
