# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UserMutations::UpdateUser, type: :graphql do
  subject { described_class }

  let(:user) { create(:user) }

  it { is_expected.to accept_argument(:attributes).of_type('UserAttributes!') }
  it { is_expected.to have_a_field(:user).returning('User') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation updateUser($id: ID!, $attributes: UserAttributes!) {
      updateUser(id: $id, attributes: $attributes) {
        user { id }
        errors { fullMessages }
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
      expect(user.reload.attributes).not_to be == old_attributes
    end

    it 'returns the update User' do
      expect(response_data.dig('updateUser', 'user', 'id'))
        .to be == user.id.to_s
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
      expect(user.reload.username).not_to be == unavailable_username
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
      expect do
        execute_graphql
      end.to raise_error CanCan::AccessDenied
    end

    it 'does not update the User' do
      old_username = other_user.username
      begin
        execute_graphql
      rescue CanCan::AccessDenied
        expect(other_user.reload.username).to be == old_username
      end
    end
  end
end
