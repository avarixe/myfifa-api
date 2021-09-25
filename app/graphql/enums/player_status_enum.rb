# frozen_string_literal: true

module Enums
  class PlayerStatusEnum < BaseTypes::BaseEnum
    graphql_name 'PlayerStatus'
    description 'State of Player availability to play in a Match'

    value 'Pending', 'Player has signed a Contract that will start in the future'
    value 'Active', 'Player is available to play in a Match'
    value 'Injured', 'Player has sustained an Injury'
    value 'Loaned', 'Player has been loaned to another Team'
  end
end
