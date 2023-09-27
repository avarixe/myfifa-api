class LinkCapToMatchEvents < ActiveRecord::Migration[7.0]
  def change
    add_reference :goals, :cap
    add_reference :goals, :assist_cap
    add_reference :substitutions, :cap
    add_reference :substitutions, :sub_cap
    add_reference :bookings, :cap

    reversible do |dir|
      %w[goals substitutions bookings].each do |table|
        execute <<~SQL.squish
          UPDATE #{table}
          SET cap_id = caps.id
          FROM caps
          WHERE caps.match_id = #{table}.match_id AND
                caps.player_id = #{table}.player_id
        SQL
      end

      execute <<~SQL.squish
        UPDATE goals
        SET assist_cap_id = caps.id
        FROM caps
        WHERE caps.match_id = goals.match_id AND
              caps.player_id = goals.assist_id
      SQL

      execute <<~SQL.squish
        UPDATE substitutions
        SET sub_cap_id = caps.id
        FROM caps
        WHERE caps.match_id = substitutions.match_id AND
              caps.player_id = substitutions.replacement_id
      SQL
    end
  end
end
