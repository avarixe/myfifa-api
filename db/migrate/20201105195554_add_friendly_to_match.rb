class AddFriendlyToMatch < ActiveRecord::Migration[6.0]
  def change
    add_column :matches, :friendly, :boolean, default: false
  end
end
