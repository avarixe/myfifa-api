# frozen_string_literal: true

module InputObjects
  class CapAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Cap record'

    argument :player_id, ID, 'ID of Player', required: false
    argument :pos, Enums::CapPositionEnum,
             'Position assigned to Player during Match', required: false
  end
end
