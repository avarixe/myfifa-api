class DropContractHistories < ActiveRecord::Migration[5.2]
  def change
    # Manually query contract_histories and create matching Contracts
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

    histories.each do |ch|
      next if Contract.exists?(
        player_id: contract_player_ids[ch['contract_id'].to_i],
        signed_date: ch['datestamp']
      )

      new_contracts << {
        player_id:         contract_player_ids[ch['contract_id'].to_i],
        signed_date:       ch['datestamp'],
        wage:              ch['wage'],
        signing_bonus:     ch['signing_bonus'],
        release_clause:    ch['release_clause'],
        performance_bonus: ch['performance_bonus'],
        bonus_req:         ch['bonus_req'],
        bonus_req_type:    ch['bonus_req_type'],
        effective_date:    ch['effective_date'],
        end_date:          ch['end_date'],
      }
    end

    Contract.import new_contracts, validate: false

    drop_table :contract_histories
  end
end
