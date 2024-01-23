# frozen_string_literal: true

module Types
  class TeamPositionCoverageType < BaseTypes::BaseObject
    description 'Positional coverage by a Team'

    Cap::POSITIONS.each do |pos|
      field pos.to_sym, [Integer],
            "Coverage of #{pos} position by active Players", null: true
    end
  end
end
