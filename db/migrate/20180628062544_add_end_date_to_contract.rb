class AddEndDateToContract < ActiveRecord::Migration[5.1]
  def change
    add_column :contracts, :end_date, :date
  end
end
