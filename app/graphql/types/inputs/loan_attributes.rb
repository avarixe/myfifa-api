# frozen_string_literal: true

module Types
  module Inputs
    class LoanAttributes < BaseInputObject
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

      argument :returned, Boolean,
               "Whether Player has returned from this Loan\n" \
               '(automatically sets Ended On to Team contemporary date)',
               required: false
    end
  end
end
