# frozen_string_literal: true

module Mutations
  class RegisterUser < Mutations::BaseMutation
    description 'Create new User in database with the provided attributes'

    argument :attributes, Types::Inputs::UserRegistrationAttributes,
             'Data object to save as User', required: true

    field :user, Types::Myfifa::UserType,
          'User that was created if saved to database', null: true
    field :errors, Types::ValidationErrorsType,
          'Errors preventing User from being created', null: true

    def resolve(attributes:)
      user = User.new(attributes.to_h)

      if user.save
        { user: user }
      else
        { errors: user.errors }
      end
    end
  end
end
