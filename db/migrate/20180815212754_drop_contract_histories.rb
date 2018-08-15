class DropContractHistories < ActiveRecord::Migration[5.2]
  def change
    # Manually query contract_histories and create matching Contracts
    Contract.transaction do
      config = Rails.configuration.database_configuration[Rails.env]

      client = PG::Connection.open(
        host: config['host'],
        dbname: config['database'],
        user: config['username'],
        password: config['password'],
      )

      histories = client.query 'SELECT * FROM contract_histories'
      contract_player_ids = Contract.pluck(:id, :player_id).to_h
      new_contracts = []

      histories.each do |history|

        new_contracts << {
          player_id: 
        }
      end

      Contract.import new_contracts, validate: false
    end

    drop_table :contract_histories
  end
end
