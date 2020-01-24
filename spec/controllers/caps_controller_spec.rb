# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CapsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team_with_players, user: user) }
  let(:player) { FactoryBot.create(:player, team: team) }
  let(:match) { FactoryBot.create(:match, team: team, home: true) }
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
      post team_caps_search_url(team)
      assert_response 401
    end

    it 'returns all Caps of select Team' do
      3.times do
        player = FactoryBot.create :player, team: team
        FactoryBot.create :cap, player: player
      end

      post team_caps_search_url(team),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      caps = Cap.where(player_id: team.players.pluck(:id))
      expect(json).to be == JSON.parse(caps.to_json)
    end
  end

  describe 'GET #index' do
    it 'requires a valid token' do
      get match_caps_url(match)
      assert_response 401
    end

    it 'returns all Caps of select Match' do
      3.times do
        player = FactoryBot.create(:player, team: team)
        FactoryBot.create :cap, match: match, player: player
      end

      FactoryBot.create :cap

      get match_caps_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(match.caps.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      cap = FactoryBot.create :cap, match: match, player: player
      get cap_url(cap)
      assert_response 401
    end

    it 'returns Cap JSON' do
      cap = FactoryBot.create :cap, match: match, player: player
      get cap_url(cap),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(cap.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post match_caps_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { cap: FactoryBot.attributes_for(:cap, match: match, player_id: player.id) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_caps_url(match),
           params: { cap: FactoryBot.attributes_for(:cap, match: match, player_id: player.id) }
      assert_response 401
    end

    it 'creates a new Cap' do
      expect(Cap.count).to be == 1
    end

    it 'returns Cap JSON' do
      expect(json).to be == Cap.last.as_json
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      cap = FactoryBot.create :cap, match: match, player: player
      patch cap_url(cap),
            params: { cap: FactoryBot.attributes_for(:cap, player: player) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      cap = FactoryBot.create :cap
      patch cap_url(cap),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { cap: FactoryBot.attributes_for(:cap, player: player) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      cap = FactoryBot.create :cap, match: match, player: player
      patch cap_url(cap),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { cap: FactoryBot.attributes_for(:cap, player: player) }
      expect(json).to be == cap.reload.as_json
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      cap = FactoryBot.create :cap, match: match, player: player
      delete cap_url(cap)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      cap = FactoryBot.create :cap
      delete cap_url(cap),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Cap' do
      cap = FactoryBot.create :cap, match: match, player: player
      delete cap_url(cap),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { cap.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
