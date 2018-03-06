class CreatePlayerHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :player_histories do |t|
      t.belongs_to :player
      t.date    :datestamp

      t.integer :ovr
      t.integer :value
      t.integer :age

      t.timestamps
    end
  end
end
