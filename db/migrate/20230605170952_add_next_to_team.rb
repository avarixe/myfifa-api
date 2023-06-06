class AddNextToTeam < ActiveRecord::Migration[7.0]
  def change
    add_reference :teams, :previous
    add_column :teams, :game, :string
    add_column :teams, :manager_name, :string

    reversible do |dir|
      dir.up do
        User.all.each do |user|
          user.teams.update_all(manager_name: user.full_name)
        end
      end
    end
  end
end
