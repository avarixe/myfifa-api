class RemoveSubstitution < ActiveRecord::Migration[7.0]
  def change
    add_column :caps, :injured, :boolean, default: false, null: false
    remove_column :caps, :subbed_out, :boolean, default: false, null: false

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE caps
          SET next_id = substitutions.sub_cap_id, injured = substitutions.injury
          FROM substitutions
          WHERE caps.id = substitutions.cap_id
        SQL
      end
    end

    drop_table :substitutions do |t|
      t.references :match
      t.integer :minute
      t.references :player
      t.references :replacement
      t.boolean :injury, default: false, null: false
      t.timestamp
      t.string :player_name
      t.string :replaced_by
      t.references :cap
      t.references :sub_cap
    end
  end
end
