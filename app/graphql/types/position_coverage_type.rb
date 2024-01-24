# frozen_string_literal: true

module Types
  class PositionCoverageType < BaseTypes::BaseObject
    description 'Positional coverage by a Player'

    Cap::POSITIONS.each do |pos|
      field pos.to_sym, Integer,
            "Coverage of #{pos} position", null: true
    end
  end
end
