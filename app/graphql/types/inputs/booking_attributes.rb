# frozen_string_literal: true

module Types
  module Inputs
    class BookingAttributes < BaseInputObject
      description 'Attributes to create/update a Booking record'

      argument :minute, Integer, 'Minute of Match this occurred', required: true
      argument :player_id, ID,
               'ID of Player booked if record exists', required: false
      argument :red_card, Boolean,
               'Whether Booking was a Yellow (false) or Red (true) Card',
               required: false
      argument :player_name, String, 'Name of Player booked', required: false
      argument :home, Boolean,
               'Whether Booking was for a Player on the Home Team',
               required: false
    end
  end
end
