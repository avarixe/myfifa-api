# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GrantAccessToken, type: :graphql do
  let(:password) { Faker::Internet.password }
  let(:user) { create(:user, password:) }

  graphql_operation <<-GQL
    mutation grantAccessToken($username: String!, $password: String!) {
      grantAccessToken(username: $username, password: $password) {
        token
        expiresAt
        user { id }
      }
    }
  GQL

  describe 'with valid password' do
    graphql_variables do
      {
        username: user.username,
        password:
      }
    end

    it 'creates a new Access Token' do
      execute_graphql
      expect(user.access_tokens.count).to eq 1
    end

    it 'returns a Token' do
      expect(response_data.dig('grantAccessToken', 'token')).to be_present
    end

    it 'returns the authenticated User' do
      expect(response_data.dig('grantAccessToken', 'user', 'id'))
        .to eq user.id.to_s
    end

    it 'returns the Token expiration date' do
      expect(response_data.dig('grantAccessToken', 'expiresAt')).to be_present
    end
  end

  describe 'with invalid password' do
    graphql_variables do
      {
        username: user.username,
        password: Faker::Internet.password
      }
    end

    it 'does not create a Token' do
      execute_graphql
      expect(user.access_tokens.count).to be_zero
    end
  end
end
