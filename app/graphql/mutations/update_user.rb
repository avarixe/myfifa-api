# frozen_string_literal: true

module Mutations
  class UpdateUser < BaseMutation
    description 'Update User with the provided attributes'

    argument :attributes, InputObjects::UserAttributes,
             'Data object to update User', required: true

    field :user, Types::UserType,
          'User that was updated if attributes were saved', null: true
    field :errors, Types::ValidationErrorsType,
          'Errors preventing changes from being applied', null: true

    def resolve(attributes:)
      user = context[:current_user]

      if user.update_without_password(attributes.to_h)
        { user: }
      else
        { errors: user.errors }
      end
    end
  end
end
