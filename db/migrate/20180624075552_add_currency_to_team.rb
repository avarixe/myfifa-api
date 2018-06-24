class AddCurrencyToTeam < ActiveRecord::Migration[5.1]
  def change
    add_column :teams, :currency, :string, default: '$'
  end
end
