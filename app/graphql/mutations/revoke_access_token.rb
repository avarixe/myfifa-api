# frozen_string_literal: true

module Mutations
  class RevokeAccessToken < BaseMutation
    description 'Revoke currently used Access Token for a User'

    argument :token, String, 'Access Token to be revoked', required: true

    field :confirmation, String,
          'Message confirming password has been changed', null: false

    def resolve(token:)
      user = context[:current_user]
      user.access_tokens.find_by(token:)&.update(revoked_at: Time.current)
      { confirmation: 'Access Token has successfully been revoked!' }
    rescue
      GraphQL::ExecutionError.new('Access Token could not be revoked')
    end
  end
end
