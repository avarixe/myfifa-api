# frozen_string_literal: true

module InputObjects
  class CapSubstitutionAttributes < BaseTypes::BaseInputObject
    description 'Attributes to substitute a Cap record'

    argument :player_id, ID, 'ID of replacement Player', required: true
    argument :pos, Enums::CapPositionEnum, 'Position of replacement Player', required: true
    argument :minute, Integer, 'Minute of Match this occurred', required: true
    argument :injured, Boolean, 'Whether the Player was injured', required: true
  end
end
