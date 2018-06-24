class CreateTransfers < ActiveRecord::Migration[5.1]
  def change
    create_table :transfers do |t|
      t.belongs_to :player

      t.date :signed_date
      t.date :effective_date
      t.string :origin
      t.string :destination

      t.integer :fee
      t.string :traded_player
      t.integer :addon_clause

      t.boolean :loan, default: false

      t.timestamps
    end

    remove_column :contracts, :origin, :string
    remove_column :contracts, :destination, :string
    remove_column :contracts, :loan, :boolean
    remove_column :contracts, :start_date, :date
    remove_column :contracts, :end_date, :date
    add_column :contracts, :duration, :integer

    drop_table :costs
  end
end
