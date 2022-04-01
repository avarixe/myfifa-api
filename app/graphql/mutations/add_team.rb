# frozen_string_literal: true

module Mutations
  class AddTeam < Mutations::BaseMutation
    description 'Create new Team in database with the provided attributes'

    argument :attributes, InputObjects::TeamAttributes,
             'Data object to save as Team', required: true

    field :team, Types::TeamType,
          'Team that was created if saved to database', null: true
    field :errors, Types::ValidationErrorsType,
          'Errors preventing Team from being created', null: true

    def resolve(attributes:)
      team = context[:current_user].teams.new(attributes.to_h)

      if team.save
        { team: }
      else
        { errors: team.errors }
      end
    end
  end
end
