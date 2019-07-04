class StandardizeDateColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :contracts, :signed_date, :signed_on
    rename_column :contracts, :effective_date, :started_on
    rename_column :contracts, :end_date, :ended_on

    rename_column :injuries, :start_date, :started_on
    rename_column :injuries, :end_date, :ended_on

    rename_column :loans, :signed_date, :signed_on
    rename_column :loans, :start_date, :started_on
    rename_column :loans, :end_date, :ended_on

    rename_column :matches, :date_played, :played_on

    rename_column :player_histories, :datestamp, :recorded_on

    rename_column :teams, :start_date, :started_on
    rename_column :teams, :current_date, :currently_on

    rename_column :transfers, :signed_date, :signed_on
    rename_column :transfers, :effective_date, :moved_on
  end
end
