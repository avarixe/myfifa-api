# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analyze::SeasonController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
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

  describe 'POST #index' do
    it 'requires a valid token' do
      post team_analyze_season_url(team, 0)
      assert_response 401
    end

    it 'retrieves seasonal data of Team' do
      FactoryBot.create_list :match, 3, team: team
      post team_analyze_season_url(team, 0),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
    end
  end
end
