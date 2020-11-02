class AddWagePercentageToLoan < ActiveRecord::Migration[6.0]
  def change
    add_column :loans, :wage_percentage, :integer
  end
end
