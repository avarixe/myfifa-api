# frozen_string_literal: true

module Types
  module Inputs
    class SquadPlayerAttributes < BaseInputObject
      description 'Attributes to create/update a Squad slot record'

      argument :id, ID, 'Unique Identifer of record', required: false
      argument :player_id, ID,
               'ID of Player assigned to this slot', required: true
      argument :pos, String, 'Position designated for this slot', required: true
    end
  end
end
