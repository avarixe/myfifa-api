class AddMoreNamesToMatchEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :goals, :assisted_by, :string
    add_column :substitutions, :player_name, :string
    add_column :substitutions, :replaced_by, :string
    add_column :bookings, :player_name, :string
  end
end
