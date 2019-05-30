class AddStageToMatch < ActiveRecord::Migration[5.2]
  def change
    add_column :matches, :stage, :string
  end
end
