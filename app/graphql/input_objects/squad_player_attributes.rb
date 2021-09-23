# frozen_string_literal: true

module InputObjects
  class SquadPlayerAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Squad slot record'

    argument :id, ID, 'Unique Identifer of record', required: false
    argument :player_id, ID,
             'ID of Player assigned to this slot', required: true
    argument :pos, Enums::CapPositionEnum,
             'Position designated for this slot', required: true
  end
end
