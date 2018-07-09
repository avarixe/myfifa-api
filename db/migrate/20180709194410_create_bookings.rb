class CreateBookings < ActiveRecord::Migration[5.1]
  def change
    create_table :bookings do |t|
      t.belongs_to :match
      t.integer :minute
      t.belongs_to :player
      t.boolean :red_card, default: false

      t.timestamps
    end
  end
end
