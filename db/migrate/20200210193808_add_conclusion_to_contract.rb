class AddConclusionToContract < ActiveRecord::Migration[6.0]
  def up
    add_column :contracts, :conclusion, :string

    Contract.all.includes(player: :team).each do |contract|
      contract.update_column(
        :conclusion,
        if contract.player.transfers.where(moved_on: contract.ended_on, origin: contract.team.title).any?
          'Transferred'
        elsif contract.player.contracts.where(started_on: contract.ended_on).any?
          'Renewed'
        elsif contract.ended_on < contract.team.currently_on
          'Expired'
        end
      )
    end
  end

  def down
    remove_column :contracts, :conclusion
  end
end
