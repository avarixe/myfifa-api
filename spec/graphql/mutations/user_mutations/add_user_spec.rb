# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UserMutations::AddUser, type: :graphql do
  subject(:mutation) { described_class }

  it 'accepts argument `attributes` of type `UserRegistrationAttributes!`' do
    expect(mutation)
      .to accept_argument(:attributes).of_type('UserRegistrationAttributes!')
  end

  it { is_expected.to have_a_field(:user).returning('User') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation registerUser($attributes: UserRegistrationAttributes!) {
      registerUser(attributes: $attributes) {
        user { id }
        errors { fullMessages }
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
      expect(response_data.dig('registerUser', 'errors', 'fullMessages'))
        .to be_present
    end
  end
end
