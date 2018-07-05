class ReplaceAgeWithBirthYear < ActiveRecord::Migration[5.1]
  def change
    rename_column :players, :age, :birth_year
    remove_column :player_histories, :age, :integer
  end
end
