# frozen_string_literal: true

module InputObjects
  class TeamAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Team record'

    argument :previous_id, ID, 'ID of previous Team', required: false

    argument :game, String, 'Name of Game', required: false
    argument :name, String, 'Name of this Team', required: false
    argument :manager_name, String, 'Name of Team Manager', required: false
    argument :started_on, GraphQL::Types::ISO8601Date,
             'Date the User started to manage this Team', required: false
    argument :currently_on, GraphQL::Types::ISO8601Date,
             'Contemporary Date of the Team', required: false
    argument :active, Boolean,
             'Whether this Team is not archived', required: false
    argument :currency, String,
             'Currency used when managing this Team', required: false
  end
end
