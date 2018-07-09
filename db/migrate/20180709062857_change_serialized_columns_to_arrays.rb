class ChangeSerializedColumnsToArrays < ActiveRecord::Migration[5.1]
  def change
    change_column :players, :sec_pos, :text, array: true, default: [], using: "sec_pos::text[]"
  end
end
