class CreateContractHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :contract_histories do |t|
      t.belongs_to :contract
      t.date :datestamp
      
      t.date :end_date
      t.integer :wage
      t.integer :signing_bonus
      t.integer :release_clause
      t.integer :performance_bonus
      t.integer :bonus_req
      t.string  :bonus_req_type

      t.timestamps
    end
  end
end
