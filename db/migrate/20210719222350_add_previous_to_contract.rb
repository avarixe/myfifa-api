class AddPreviousToContract < ActiveRecord::Migration[6.1]
  def change
    add_reference :contracts, :previous

    reversible do |dir|
      dir.up do
        Contract.where(conclusion: 'Renewed').each do |contract|
          renewal = Contract.find_by(
            player_id: contract.player_id,
            started_on: contract.ended_on
          )
          renewal.update(previous: contract)
        end
      end
    end
  end
end
