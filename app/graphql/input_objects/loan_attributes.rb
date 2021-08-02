# frozen_string_literal: true

module InputObjects
  class LoanAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Loan record'

    argument :started_on, GraphQL::Types::ISO8601Date,
             'Date Player departs to Destination Team', required: true
    argument :ended_on, GraphQL::Types::ISO8601Date,
             'Date Player returns to Origin Team', required: false
    argument :destination, String,
             'Name of Team this Player is loaned To', required: true
    argument :origin, String,
             'Name of Team this Player is loaned From', required: true
    argument :wage_percentage, Integer,
             'Percentage of Wage to be paid by Destination Team',
             required: false
    argument :transfer_fee, Integer,
             'Transfer Fee paid to the original Team ' \
             'if Loan-to-Buy option is activated', required: false
    argument :addon_clause, Integer,
             'Percentage of Transfer Fee to be received from the ' \
             'destination Team if they sell this Player ' \
             'after Loan-to-Buy option is activated', required: false

    argument :activated_buy_option, Boolean,
             "Whether the Loan-to-Buy option has been activated\n" \
             '(automatically creates associated Transfer)',
             required: false
  end
end
