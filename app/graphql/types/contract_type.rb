# frozen_string_literal: true

module Types
  class ContractType < BaseTypes::BaseObject
    description 'Record of an Agreement for a Player to join a Team'

    field :id, ID, 'Unique Identifer of record', null: false
    field :player_id, ID, 'ID of Player', null: false
    field :signed_on, GraphQL::Types::ISO8601Date,
          'Date of Team when this Contract was created', null: false
    field :wage, Integer, 'Weekly Wage for this Player', null: false
    field :signing_bonus, Integer,
          'Initial Payment upon signing this Contract', null: true
    field :release_clause, Integer,
          'Required Amount to skip Transfer Negotiation with another Team',
          null: true
    field :performance_bonus, Integer,
          'Promised Payment upon meeting certain performance milestones',
          null: true
    field :bonus_req, Integer,
          'Number of specified metric to receive Performance Bonus', null: true
    field :bonus_req_type, String,
          'Metric to track for receiving Performance Bonus', null: true
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false
    field :ended_on, GraphQL::Types::ISO8601Date,
          'Date on which this Contract expired or will expire', null: false
    field :started_on, GraphQL::Types::ISO8601Date,
          'Date on which this Contract becomes active', null: false
    field :conclusion, Enums::ContractConclusionEnum,
          'How this Contract ended (e.g. Expired, Transferred, etc.)',
          null: true

    field :player, PlayerType, 'Player pertaining to this Contract', null: false
  end
end
