# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UpdateUser, type: :graphql do
  subject { described_class }

  let(:user) { create :user }

  it { is_expected.to accept_argument(:attributes).of_type('UserAttributes!') }
  it { is_expected.to have_a_field(:user).returning('User') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation updateUser($attributes: UserAttributes!) {
      updateUser(attributes: $attributes) {
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
end
