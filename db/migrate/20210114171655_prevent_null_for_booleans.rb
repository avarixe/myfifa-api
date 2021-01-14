class PreventNullForBooleans < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        Booking.where(red_card: nil).update_all(red_card: false)
        Booking.where(home: nil).update_all(home: false)
        Cap.where(subbed_out: nil).update_all(subbed_out: false)
        Goal.where(home: nil).update_all(home: false)
        Goal.where(own_goal: nil).update_all(own_goal: false)
        Goal.where(penalty: nil).update_all(penalty: false)
        Match.where(extra_time: nil).update_all(extra_time: false)
        Match.where(friendly: nil).update_all(friendly: false)
        Player.where(youth: nil).update_all(youth: false)
        Stage.where(table: nil).update_all(table: false)
        Substitution.where(injury: nil).update_all(injury: false)
        Team.where(active: nil).update_all(active: true)
        User.where(admin: nil).update_all(admin: false)
      end
    end

    change_column_null :bookings, :red_card, false
    change_column_null :bookings, :home, false
    change_column_null :caps, :subbed_out, false
    change_column_null :goals, :home, false
    change_column_null :goals, :own_goal, false
    change_column_null :goals, :penalty, false
    change_column_null :matches, :extra_time, false
    change_column_null :matches, :friendly, false
    change_column_null :players, :youth, false
    change_column_null :stages, :table, false
    change_column_null :substitutions, :injury, false
    change_column_null :teams, :active, false
    change_column_null :users, :admin, false
    change_column_default :players, :youth, from: true, to: false
  end
end
