# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GrantAccessToken, type: :graphql do
  subject { described_class }

  let(:password) { Faker::Internet.password }
  let(:user) { create :user, password: }

  it { is_expected.to accept_argument(:username).of_type('String!') }
  it { is_expected.to accept_argument(:password).of_type('String!') }
  it { is_expected.to have_a_field(:token).returning('String') }
  it { is_expected.to have_a_field(:expires_at).returning('ISO8601DateTime') }
  it { is_expected.to have_a_field(:user).returning('User') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation grantAccessToken($username: String!, $password: String!) {
      grantAccessToken(username: $username, password: $password) {
        token
        expiresAt
        user { id }
        errors { fullMessages }
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
      expect(user.access_tokens.count).to be == 1
    end

    it 'returns a Token' do
      expect(response_data.dig('grantAccessToken', 'token')).to be_present
    end

    it 'returns the authenticated User' do
      expect(response_data.dig('grantAccessToken', 'user', 'id'))
        .to be == user.id.to_s
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
      expect(user.access_tokens.count).to be == 0
    end
  end
end
