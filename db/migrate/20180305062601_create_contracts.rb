class CreateContracts < ActiveRecord::Migration[5.1]
  def change
    create_table :contracts do |t|
      t.belongs_to :player
      t.date :signed_date
      t.date :start_date
      t.date :end_date

      t.string :origin
      t.string :destination

      t.boolean :loan, default: false
      t.boolean :youth, default: false

      t.integer :wage
      t.integer :signing_bonus
      t.integer :release_clause
      t.integer :performance_bonus
      t.integer :bonus_req
      t.string  :bonus_req_type

      t.timestamps
    end
  end
end
