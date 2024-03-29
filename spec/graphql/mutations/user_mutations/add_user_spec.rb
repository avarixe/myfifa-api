# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UserMutations::AddUser, type: :graphql do
  graphql_operation <<-GQL
    mutation registerUser($attributes: UserRegistrationAttributes!) {
      registerUser(attributes: $attributes) {
        user { id }
      }
    }
  GQL

  describe 'with valid attributes' do
    graphql_variables do
      { attributes: graphql_attributes_for(:user) }
    end

    it 'creates a new User' do
      execute_graphql
      expect(User.count).to be == 1
    end

    it 'returns the created User' do
      expect(response_data.dig('registerUser', 'user', 'id'))
        .to be == User.first.id.to_s
    end
  end

  describe 'with invalid attributes' do
    let(:user) { create(:user) }

    graphql_variables do
      { attributes: graphql_attributes_for(:user, email: user.email) }
    end

    it 'returns errors if attributes are not valid' do
      expect(response['errors']).to be_present
    end
  end
end
