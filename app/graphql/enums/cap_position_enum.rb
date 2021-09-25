# frozen_string_literal: true

module Enums
  class CapPositionEnum < BaseTypes::BaseEnum
    graphql_name 'CapPosition'
    description 'Positions utilized by Players during a Match'

    value 'GK', 'Goalkeeper'
    value 'LB', 'Left Back'
    value 'LWB', 'Left Wing Back'
    value 'LCB', 'Left Center Back'
    value 'CB', 'Center Back'
    value 'RCB', 'Right Center Back'
    value 'RB', 'Right Back'
    value 'RWB', 'Right Wing Back'
    value 'LM', 'Left Midfielder'
    value 'LDM', 'Left Defensive Midfielder'
    value 'LCM', 'Left Center Midfielder'
    value 'CDM', 'Center Defensive Midfielder'
    value 'CM', 'Center Midfielder'
    value 'RDM', 'Right Defensive Midfielder'
    value 'RCM', 'Right Center Midfielder'
    value 'RM', 'Right Midfielder'
    value 'LAM', 'Left Attacking Midfielder'
    value 'CAM', 'Central Attacking Midfielder'
    value 'RAM', 'Right Attacking Midfielder'
    value 'LW', 'Left Winger'
    value 'CF', 'Center Forward'
    value 'LS', 'Left Striker'
    value 'ST', 'Striker'
    value 'RS', 'Right Striker'
    value 'RW', 'Right Winger'
  end
end
