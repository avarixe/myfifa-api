# frozen_string_literal: true

module Types
  module Inputs
    class SubstitutionAttributes < BaseInputObject
      argument :minute, Integer, required: true
      argument :player_id, Integer, required: true
      argument :replacement_id, Integer, required: true
      argument :injury, Boolean, required: true
    end
  end
end
