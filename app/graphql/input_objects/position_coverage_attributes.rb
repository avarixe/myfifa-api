# frozen_string_literal: true

module InputObjects
  class PositionCoverageAttributes < BaseTypes::BaseInputObject
    description "Attributes to set Player's positional coverage"

    Cap::POSITIONS.each do |pos|
      argument pos.to_sym, Integer,
               "Coverage of #{pos} position", required: false
    end
  end
end
