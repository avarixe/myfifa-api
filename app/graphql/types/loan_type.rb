# frozen_string_literal: true

module Types
  class LoanType < BaseTypes::BaseObject
    description 'Record of a Player sent on loan to a different Team'

    field :id, ID, 'Unique Identifer of record', null: false
    field :player_id, ID, 'ID of Player', null: false
    field :started_on, GraphQL::Types::ISO8601Date,
          'Date Player departs to Destination Team', null: false
    field :ended_on, GraphQL::Types::ISO8601Date,
          'Date Player returns to Origin Team', null: true
    field :destination, String,
          'Name of Team this Player is loaned To', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :origin, String,
          'Name of Team this Player is loaned From', null: false
    field :signed_on, GraphQL::Types::ISO8601Date,
          'Date of Team when Loan is created', null: true
    field :wage_percentage, Integer,
          'Percentage of Wage to be paid by Destination Team', null: true
    field :transfer_fee, Integer,
          'Transfer Fee paid to the original Team ' \
          'if Loan-to-Buy option is activated', null: true
    field :addon_clause, Integer,
          'Percentage of Transfer Fee to be received from the ' \
          'destination Team if they sell this Player ' \
          'after Loan-to-Buy option is activated', null: true

    field :player, PlayerType, 'Loaned Player', null: false
  end
end
