class RemoveContractHistory < ActiveRecord::Migration[5.2]
  def up
    drop_table :contract_histories
  end

  def down
    create_table :contract_histories, force: :cascade do |t|
      t.bigint :contract_id
      t.date :recorded_on
      t.integer :wage
      t.integer :signing_bonus
      t.integer :release_clause
      t.integer :performance_bonus
      t.integer :bonus_req
      t.string :bonus_req_type
      t.date :ended_on
      t.date :started_on
      t.timestamps
    end
  end
end
