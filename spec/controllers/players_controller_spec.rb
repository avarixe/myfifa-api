# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayersController, type: :request do
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

  describe 'GET #index' do
    it 'requires a valid token' do
      get team_players_url(team)
      assert_response 401
    end

    it 'returns all Players of select Team' do
      FactoryBot.create_list :player, 10, team: team

      another_team = FactoryBot.create(:team, user: user)
      FactoryBot.create :player, team: another_team

      get team_players_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(team.players.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      player = FactoryBot.create :player, team: team
      get player_url(player)
      assert_response 401
    end

    it 'returns Player JSON with History' do
      player = FactoryBot.create :player, team: team

      get player_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(player.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post team_players_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { player: FactoryBot.attributes_for(:player) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post team_players_url(team),
           params: { player: FactoryBot.attributes_for(:player) }
      assert_response 401
    end

    it 'creates a new Player' do
      expect(Player.count).to be == 1
    end

    it 'returns Player JSON' do
      player = Player.last
      expect(json).to be == JSON.parse(player.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      player = FactoryBot.create :player, team: team
      patch player_url(player),
            params: { player: FactoryBot.attributes_for(:player) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      player = FactoryBot.create :player
      patch player_url(player),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { player: FactoryBot.attributes_for(:player) }
      assert_response 403
    end

    it 'returns updated Player JSON' do
      player = FactoryBot.create :player, team: team
      patch player_url(player),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { player: FactoryBot.attributes_for(:player) }
      player.reload
      expect(json).to be == JSON.parse(player.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      player = FactoryBot.create :player, team: team
      delete player_url(player)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      player = FactoryBot.create(:player)
      delete player_url(player),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Player' do
      player = FactoryBot.create :player, team: team
      delete player_url(player),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { player.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #history' do
    let(:player) { FactoryBot.create(:player, team: team) }

    it 'requires a valid token' do
      get history_player_url(player)
      assert_response 401
    end

    it 'returns history JSON' do
      get history_player_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(player.player_histories.to_json)
    end
  end

  describe 'GET #current_loan' do
    let(:player) { FactoryBot.create(:player, team: team) }

    before do
      FactoryBot.create(:loan, player: player)
      get current_loan_player_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
    end

    it 'requires a valid token', skip_request: true do
      get current_loan_player_url(player)
      assert_response 401
    end

    it 'returns Loan JSON' do
      expect(json).to be == JSON.parse(player.loans.last.to_json)
    end
  end

  describe 'GET #current_injury' do
    let(:player) { FactoryBot.create(:player, team: team) }

    before do
      FactoryBot.create(:injury, player: player)
      get current_injury_player_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
    end

    it 'requires a valid token', skip_request: true do
      get current_injury_player_url(player)
      assert_response 401
    end

    it 'returns Injury JSON' do
      expect(json).to be == JSON.parse(player.injuries.last.to_json)
    end
  end
end
