# frozen_string_literal: true

module Mutations
  class ChangePassword < BaseMutation
    description 'Change the password for a User'

    argument :attributes, Types::Inputs::UserPasswordChangeAttributes,
             'Data object to change the password for User', required: true

    field :confirmation, String,
          'Message confirming password has been changed', null: true
    field :errors, Types::ValidationErrorsType,
          'Errors preventing password from being changed', null: true

    def resolve(attributes:)
      user = context[:current_user]

      if user.update_with_password(attributes.to_h)
        { confirmation: 'Password has been successfully changed!' }
      else
        { errors: user.errors }
      end
    end
  end
end
