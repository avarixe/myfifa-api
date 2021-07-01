# frozen_string_literal: true

module Types
  module Inputs
    class BookingAttributes < BaseInputObject
      argument :minute, Integer, required: true
      argument :player_id, Integer, required: false
      argument :red_card, Boolean, required: true
      argument :player_name, String, required: false
      argument :home, Boolean, required: true
    end
  end
end
