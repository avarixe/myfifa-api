# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:application) {
    Doorkeeper::Application.create!(
      name: Faker::Company.name,
      redirect_uri: "https://#{Faker::Internet.domain_name}"
    )
  }
  let(:token) {
    Doorkeeper::AccessToken.create!(
      application: application,
      resource_owner_id: user.id
    )
  }

  describe 'POST users/registrations#create' do
    before do
      user_attributes = FactoryBot.attributes_for :user
      post user_registration_url(format: :json),
           params: { user: user_attributes }
    end

    it 'creates a user' do
      expect(User.count).to be == 1
    end

    it 'returns the User information' do
      expect(json).to be == JSON.parse(User.last.to_json)
    end
  end

  describe 'POST tokens#create' do
    it 'creates a token' do
      post oauth_token_url,
           params: {
             grant_type: 'password',
             username:   user.username,
             password:   user.password
           }
      assert_response :success
    end
  end

  describe 'POST tokens#revoke' do
    it 'removes a token' do
      post oauth_revoke_url,
           params: {
             client_id: application.uid,
             client_secret: application.secret
           },
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
    end
  end
end
