# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MatchesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team_with_players, user: user) }
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
      get team_matches_url(team)
      assert_response 401
    end

    it 'returns all Matches of select Team' do
      FactoryBot.create_list :match, 3, team: team
      FactoryBot.create :match

      get team_matches_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(team.matches.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      game = FactoryBot.create :match, team: team
      get match_url(game)
      assert_response 401
    end

    it 'returns Match JSON' do
      game = FactoryBot.create :match, team: team
      get match_url(game),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(game.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post team_matches_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { match: FactoryBot.attributes_for(:match) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post team_matches_url(team),
           params: { match: FactoryBot.attributes_for(:match) }
      assert_response 401
    end

    it 'creates a new Match' do
      expect(Match.count).to be == 1
    end

    it 'returns Match JSON' do
      game = Match.last
      expect(json).to be == JSON.parse(game.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      game = FactoryBot.create :match, team: team
      patch match_url(game),
            params: { match: FactoryBot.attributes_for(:match) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      game = FactoryBot.create :match
      patch match_url(game),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { match: FactoryBot.attributes_for(:match) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      game = FactoryBot.create :match, team: team
      patch match_url(game),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { match: FactoryBot.attributes_for(:match) }
      expect(json).to be == JSON.parse(game.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      game = FactoryBot.create :match, team: team
      delete match_url(game)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      game = FactoryBot.create :match
      delete match_url(game),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Match' do
      game = FactoryBot.create :match, team: team
      delete match_url(game),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { game.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'GET #events' do
    let(:game) { FactoryBot.create(:match, team: team) }

    before do
      FactoryBot.create_list :home_goal, Faker::Number.between(0, 3), match: game
      FactoryBot.create_list :away_goal, Faker::Number.between(0, 3), match: game
      team.players.each_with_index do |player, i|
        FactoryBot.create :cap,
                          match: game,
                          player: player,
                          pos: Cap::POSITIONS[i]
      end
      player_ids = game.players.pluck(:id)
      Faker::Number.between(0, 2).times do
        FactoryBot.create :booking,
                          match: game,
                          player_id: player_ids.sample
      end
      Faker::Number.between(0, 2).times do
        FactoryBot.create :substitution,
                          match: game,
                          player_id: player_ids.sample
      end
    end

    it 'requires a valid token' do
      get events_match_url(game)
      assert_response 401
    end

    it 'returns Match Events JSON' do
      get events_match_url(game),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(game.events.to_json)
    end
  end

  describe 'POST #apply_squad' do
    let(:game) { FactoryBot.create(:match, team: team) }
    let(:squad) { FactoryBot.create(:squad, team: team) }

    it 'requires a valid token' do
      post apply_squad_match_url(game),
           params: { squad_id: squad.id }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      other_match = FactoryBot.create :match
      post apply_squad_match_url(other_match),
           headers: { 'Authorization' => "Bearer #{token.token}" },
           params: { squad_id: squad.id }
      assert_response 403
    end

    it 'returns updated Match Performances JSON' do
      post apply_squad_match_url(game),
           headers: { 'Authorization' => "Bearer #{token.token}" },
           params: { squad_id: squad.id }
      expect(json).to be == JSON.parse(game.reload.to_json)
    end
  end
end
