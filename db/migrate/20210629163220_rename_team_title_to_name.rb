class RenameTeamTitleToName < ActiveRecord::Migration[6.1]
  def change
    rename_column :teams, :title, :name
  end
end
