class CreateMatchLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :match_logs do |t|
      t.belongs_to :match
      t.belongs_to :player

      t.string  :pos
      t.integer :start
      t.integer :stop

      t.timestamps
    end
  end
end
