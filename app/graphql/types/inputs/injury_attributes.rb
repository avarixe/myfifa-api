# frozen_string_literal: true

module Types
  module Inputs
    class InjuryAttributes < BaseInputObject
      description 'Attributes to create/update a Injury record'

      argument :started_on, GraphQL::Types::ISO8601Date,
               'Date Player was afflicted by this Injury', required: false
      argument :ended_on, GraphQL::Types::ISO8601Date,
               'Date Player recovered from this Injury', required: false
      argument :description, String,
               'Description of this Injury', required: true

      argument :recovered, Boolean,
               "Whether Player has recovered from this Injury\n" \
               '(automatically sets Ended On to Team contemporary date)',
               required: false
    end
  end
end
