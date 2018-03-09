class CreateInjuries < ActiveRecord::Migration[5.1]
  def change
    create_table :injuries do |t|
      t.belongs_to :player
      t.date :start_date
      t.date :end_date
      t.string :description

      t.timestamps
    end
  end
end
