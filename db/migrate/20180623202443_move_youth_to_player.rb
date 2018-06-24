class MoveYouthToPlayer < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :youth, :boolean, default: true

    remove_column :contracts, :youth
  end
end
