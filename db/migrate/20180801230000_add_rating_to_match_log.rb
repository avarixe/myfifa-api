class AddRatingToMatchLog < ActiveRecord::Migration[5.2]
  def change
    add_column :match_logs, :rating, :integer, default: 3
  end
end
