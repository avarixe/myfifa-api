# frozen_string_literal: true

require 'rails_helper'

describe Mutations::RevokeAccessToken, type: :graphql do
  let(:token) { create(:access_token) }
  let!(:user) { token.user }

  graphql_operation <<-GQL
    mutation revokeAccessToken($token: String!) {
      revokeAccessToken(token: $token) {
        confirmation
      }
    }
  GQL

  describe 'with Authorization header' do
    graphql_variables do
      { token: token.token }
    end

    graphql_context do
      { current_user: user }
    end

    it 'revokes the Access Token' do
      execute_graphql
      expect(token.reload).to be_revoked
    end

    it 'returns a confirmation message' do
      expect(response_data.dig('revokeAccessToken', 'confirmation')).to be_present
    end
  end

  describe 'without Authorization header' do
    graphql_variables do
      { token: token.token }
    end

    it 'does not revoke the Access Token' do
      execute_graphql
      expect(token.reload).not_to be_revoked
    end
  end
end
