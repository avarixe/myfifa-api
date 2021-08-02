# frozen_string_literal: true

module InputObjects
  class InjuryAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Injury record'

    argument :started_on, GraphQL::Types::ISO8601Date,
             'Date Player was afflicted by this Injury', required: false
    argument :ended_on, GraphQL::Types::ISO8601Date,
             'Date Player recovered from this Injury', required: false
    argument :description, String,
             'Description of this Injury', required: true

    argument :duration, InjuryDurationAttributes,
             'Duration of this Injury (automatically sets End Date)',
             required: false
  end
end
