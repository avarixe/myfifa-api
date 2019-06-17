# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerHistoriesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
  let(:player) { FactoryBot.create(:player, team: team) }
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

  describe 'POST #search' do
    it 'requires a valid token' do
      post team_player_histories_search_url(team)
      assert_response 401
    end

    it 'returns all Caps of select Team' do
      3.times do
        FactoryBot.create :player, team: team
      end

      post team_player_histories_search_url(team),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      histories = PlayerHistory.where(player_id: team.players.pluck(:id))
      expect(json).to be == JSON.parse(histories.to_json)
    end

    it 'filters Cap results by filter params'
  end
end
