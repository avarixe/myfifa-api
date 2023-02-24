# frozen_string_literal: true

module Mutations
  class GrantAccessToken < BaseMutation
    description 'Authenticate and create Access Token for a User'

    argument :username, String,
             'Username of the User to authenticate', required: true
    argument :password, String,
             'Password authenticating the User', required: true

    field :token, String, 'Access Token enabling API access', null: false
    field :expires_at, GraphQL::Types::ISO8601DateTime,
          'Time at which this Access Token will become invalid', null: false
    field :user, Types::UserType, 'User that was authenticated', null: false

    def resolve(username:, password:)
      user = User.find_by(username:)

      if user&.valid_password? password
        token = user.access_tokens.create!
        { token: token.token, expires_at: token.expires_at, user: }
      else
        GraphQL::ExecutionError.new('Invalid Username/Password')
      end
    end
  end
end
