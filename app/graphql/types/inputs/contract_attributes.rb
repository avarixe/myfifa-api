# frozen_string_literal: true

module Types
  module Inputs
    class ContractAttributes < BaseInputObject
      description 'Attributes to create/update a Contract record'

      argument :wage, Integer, 'Weekly Wage for this Player', required: true
      argument :signing_bonus, Integer,
               'Initial Payment upon signing this Contract', required: false
      argument :release_clause, Integer,
               'Required Amount to skip Transfer Negotiation with another Team',
               required: false
      argument :performance_bonus, Integer,
               'Promised Payment upon meeting certain performance milestones',
               required: false
      argument :bonus_req, Integer,
               'Number of specified metric to receive Performance Bonus',
               required: false
      argument :bonus_req_type, String,
               'Metric to track for receiving Performance Bonus',
               required: false
      argument :ended_on, GraphQL::Types::ISO8601Date,
               'Date on which this Contract expired or will expire',
               required: true
      argument :started_on, GraphQL::Types::ISO8601Date,
               'Date on which this Contract becomes active', required: true

      argument :num_seasons, Integer,
               'Number of Season this Contract will be active for',
               required: false
    end
  end
end
