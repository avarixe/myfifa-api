# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UserMutations::UpdateUser, type: :graphql do
  let(:user) { create(:user) }

  graphql_operation <<-GQL
    mutation updateUser($id: ID!, $attributes: UserAttributes!) {
      updateUser(id: $id, attributes: $attributes) {
        user { id }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  describe 'with valid attributes' do
    graphql_variables do
      {
        id: user.id,
        attributes:
          graphql_attributes_for(:user).except('password', 'passwordConfirmation')
      }
    end

    it 'updates the User' do
      old_attributes = user.attributes
      execute_graphql
      expect(user.reload.attributes).not_to eq old_attributes
    end

    it 'returns the update User' do
      expect(response_data.dig('updateUser', 'user', 'id'))
        .to eq user.id.to_s
    end
  end

  describe 'with invalid attributes' do
    let(:unavailable_username) { create(:user).username }

    graphql_variables do
      {
        id: user.id,
        attributes: {
          username: unavailable_username
        }
      }
    end

    it 'does not update the User' do
      execute_graphql
      expect(user.reload.username).not_to eq unavailable_username
    end
  end

  describe 'for a different User' do
    let(:other_user) { create(:user) }

    graphql_variables do
      {
        id: other_user.id,
        attributes:
          graphql_attributes_for(:user).except('password', 'passwordConfirmation')
      }
    end

    it 'raises authorization error' do
      expect(response['errors']).to be_present
    end

    it 'does not update the User' do
      old_username = other_user.username
      execute_graphql
      expect(other_user.reload.username).to eq old_username
    end
  end
end
