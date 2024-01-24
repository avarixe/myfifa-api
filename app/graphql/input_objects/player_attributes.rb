# frozen_string_literal: true

module InputObjects
  class PlayerAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Player record'

    argument :name, String, 'Name of this Player', required: false
    argument :nationality, String,
             'Nationality of this Player', required: false
    argument :pos, Enums::PlayerPositionEnum,
             'Primary Position of this Player', required: false
    argument :sec_pos, [Enums::PlayerPositionEnum],
             'List of Secondary Positions of this Player', required: false
    argument :ovr, Integer, 'Overall Rating of this Player', required: false
    argument :value, Integer, 'Value of this Player', required: false
    argument :youth, Boolean,
             'Whether this Player came from the Youth Academy',
             required: false
    argument :kit_no, Integer,
             'Kit Number assigned to this Player', required: false

    argument :age, Integer, 'Age of this Player', required: false

    argument :contracts_attributes, [ContractAttributes],
             'List of attributes for Contracts bound to this Player',
             required: false
  end
end
