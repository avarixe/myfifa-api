# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ChangePassword, type: :graphql do
  subject(:mutation) { described_class }

  let(:password) { Faker::Internet.password }
  let(:user) { create :user, password: }

  it 'accepts argument `attributes` of type `UserPasswordChangeAttributes!`' do
    expect(mutation)
      .to accept_argument(:attributes).of_type('UserPasswordChangeAttributes!')
  end

  it { is_expected.to have_a_field(:confirmation).returning('String') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation <<-GQL
    mutation changePassword($attributes: UserPasswordChangeAttributes!) {
      changePassword(attributes: $attributes) {
        confirmation
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
          graphql_attributes_for(:user)
            .slice('password', 'passwordConfirmation')
            .merge(currentPassword: password)
      }
    end

    it 'updates the Password' do
      execute_graphql
      expect(user.reload.valid_password?(password)).not_to be true
    end

    it 'returns a confirmation message' do
      expect(response_data.dig('changePassword', 'confirmation')).to be_present
    end
  end

  describe 'without password confirmation' do
    graphql_variables do
      {
        attributes: {
          password: Faker::Internet.password,
          passwordConfirmation: Faker::Internet.password,
          currentPassword: password
        }
      }
    end

    it 'will not update the Password' do
      execute_graphql
      expect(user.reload.valid_password?(password)).to be true
    end

    it 'will return an error message' do
      expect(response_data.dig('changePassword', 'errors')).to be_present
    end
  end

  describe 'without current password' do
    graphql_variables do
      new_password = Faker::Internet.password
      {
        attributes: {
          password: new_password,
          passwordConfirmation: new_password,
          currentPassword: Faker::Internet.password
        }
      }
    end

    it 'will not update the Password' do
      execute_graphql
      expect(user.reload.valid_password?(password)).to be true
    end

    it 'will return an error message' do
      expect(response_data.dig('changePassword', 'errors')).to be_present
    end
  end
end
