# frozen_string_literal: true

module Types
  module Inputs
    class CapAttributes < BaseInputObject
      argument :player_id, Integer, required: true
      argument :pos, String, required: true
    end
  end
end
