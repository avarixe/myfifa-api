# frozen_string_literal: true

module Types
  module Inputs
    class SubstitutionAttributes < BaseInputObject
      description 'Attributes to create/update a Substitution record'

      argument :minute, Integer, 'Minute of Match this occurred', required: true
      argument :player_id, ID,
               'ID of the Player who was replaced', required: true
      argument :replacement_id, ID,
               'ID of the replacement Player', required: true
      argument :injury, Boolean,
               'Whether the Player was replaced due to injury', required: false
    end
  end
end
