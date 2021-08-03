# frozen_string_literal: true

module InputObjects
  class TransferAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Transfer record'

    argument :signed_on, GraphQL::Types::ISO8601Date,
             'Date this Transfer was signed', required: true
    argument :moved_on, GraphQL::Types::ISO8601Date,
             'Date when Player moved to a different Team', required: true
    argument :origin, String,
             'Name of Team this Player is transferred from', required: true
    argument :destination, String,
             'Name of Team this Player is transferred to', required: true
    argument :fee, Integer,
             'Transfer Fee paid to the original Team', required: false
    argument :traded_player, String,
             'Name of Player swapped for this Transfer', required: false
    argument :addon_clause, Integer,
             'Percentage of Transfer Fee to be received from the ' \
             'destination Team if they sell this Player',
             required: false
  end
end
