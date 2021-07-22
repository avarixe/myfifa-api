# frozen_string_literal: true

module Types
  module Inputs
    class CapAttributes < BaseInputObject
      description 'Attributes to create/update a Cap record'

      argument :player_id, ID, 'ID of Player', required: false
      argument :pos, String,
               'Position assigned to Player during Match', required: false
    end
  end
end
