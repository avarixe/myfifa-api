# frozen_string_literal: true

module Mutations
  class GrantAccessToken < BaseMutation
    description 'Authenticate and create Access Token for a User'

    argument :username, String,
             'Username of the User to authenticate', required: true
    argument :password, String,
             'Password authenticating the User', required: true

    field :token, String, 'Access Token enabling API access', null: true
    field :expires_at, GraphQL::Types::ISO8601DateTime,
          'Time at which this Access Token will become invalid', null: true
    field :user, Types::UserType, 'User that was authenticated', null: true
    field :errors, Types::ValidationErrorsType,
          'Errors preventing User from being authenticated', null: true

    def resolve(username:, password:)
      user = User.find_by(username: username)

      if user&.valid_password? password
        token = user.access_tokens.create!
        {
          token: token.token,
          expires_at: token.expires_at,
          user: user
        }
      else
        {
          errors: {
            details: 'Invalid Username/Password',
            full_messages: ['Invalid Username/Password']
          }
        }
      end
    end
  end
end
