class AddHomeToBooking < ActiveRecord::Migration[6.0]
  def up
    add_column :bookings, :home, :boolean, default: false

    Booking.includes(match: :team).each do |booking|
      booking.update(home: booking.match.team_home?)
    end
  end

  def down
    remove_column :bookings, :home
  end
end
