class AddSetPieceToGoal < ActiveRecord::Migration[7.0]
  def change
    add_column :goals, :set_piece, :string, limit: 20

    reversible do |dir|
      dir.up do
        Goal.where(penalty: true).update_all(set_piece: 'PK')
      end
      dir.down do
        Goal.where(set_piece: 'PK').update_all(penalty: true)
      end
    end

    remove_column :goals, :penalty, :boolean
  end
end
