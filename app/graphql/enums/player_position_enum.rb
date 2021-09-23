# frozen_string_literal: true

module Enums
  class PlayerPositionEnum < BaseTypes::BaseEnum
    graphql_name 'PlayerPosition'
    description 'Position of Player for Development/Career'

    value 'GK', 'Goalkeeper'
    value 'RB', 'Right Back'
    value 'RWB', 'Right Wing Back'
    value 'CB', 'Center Back'
    value 'LB', 'Left Back'
    value 'LWB', 'Left Wing Back'
    value 'RM', 'Right Midfielder'
    value 'CDM', 'Center Defensive Midfielder'
    value 'CM', 'Center Midfielder'
    value 'CAM', 'Central Attacking Midfielder'
    value 'LM', 'Left Midfielder'
    value 'RW', 'Right Winger'
    value 'CF', 'Center Forward'
    value 'ST', 'Striker'
    value 'LW', 'Left Winger'
  end
end
