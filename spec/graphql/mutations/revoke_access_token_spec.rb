# frozen_string_literal: true

require 'rails_helper'

describe Mutations::RevokeAccessToken, type: :graphql do
  subject { described_class }

  let(:token) { create :access_token }

  it { is_expected.to accept_argument(:token).of_type('String!') }
  it { is_expected.to have_a_field(:confirmation).returning('String') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation revokeAccessToken($token: String!) {
      revokeAccessToken(token: $token) {
        confirmation
        errors { fullMessages }
      }
    }
  GQL

  describe 'with Authorization header' do
    graphql_variables do
      { token: token.token }
    end

    graphql_context do
      { current_user: token.user, pundit: PunditProvider.new(user: token.user) }
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
