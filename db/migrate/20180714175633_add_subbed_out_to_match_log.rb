class AddSubbedOutToMatchLog < ActiveRecord::Migration[5.2]
  def change
    add_column :match_logs, :subbed_out, :boolean, default: false
  end
end
