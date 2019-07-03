class AddOriginToLoan < ActiveRecord::Migration[5.2]
  def change
    add_column :loans, :origin, :string
    add_column :loans, :signed_date, :date
  end
end
