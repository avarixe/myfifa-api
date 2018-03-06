class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.belongs_to :user
      t.string :title
      t.date :start_date
      t.date :current_date
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
