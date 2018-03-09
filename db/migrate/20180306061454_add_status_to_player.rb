class AddStatusToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :status, :string
  end
end
