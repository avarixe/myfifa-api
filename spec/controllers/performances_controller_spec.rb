require 'rails_helper'

RSpec.describe PerformancesController, type: :request do
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

  describe 'GET #index' do
    it 'requires a valid token' do
      get match_performances_url(match)
      assert_response 401
    end

    it 'returns all Performances of select Match' do
      3.times do
        player = FactoryBot.create(:player, team: team)
        FactoryBot.create :performance, match: match, player: player
      end

      FactoryBot.create :performance

      get match_performances_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(match.performances.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      performance = FactoryBot.create :performance, match: match, player: player
      get performance_url(performance)
      assert_response 401
    end

    it 'returns Performance JSON' do
      performance = FactoryBot.create :performance, match: match, player: player
      get performance_url(performance),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(performance.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        post match_performances_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { performance: FactoryBot.attributes_for(:performance, match: match, player_id: player.id) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_performances_url(match),
           params: { performance: FactoryBot.attributes_for(:performance, match: match, player_id: player.id) }
      assert_response 401
    end

    it 'creates a new Performance' do
      expect(Performance.count).to be == 1
    end

    it 'returns Performance JSON' do
      expect(json).to be == Performance.last.as_json
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      performance = FactoryBot.create :performance, match: match, player: player
      patch performance_url(performance),
            params: { performance: FactoryBot.attributes_for(:performance, player: player) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      performance = FactoryBot.create :performance
      patch performance_url(performance),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { performance: FactoryBot.attributes_for(:performance, player: player) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      performance = FactoryBot.create :performance, match: match, player: player
      patch performance_url(performance),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { performance: FactoryBot.attributes_for(:performance, player: player) }
      expect(json).to be == performance.reload.as_json
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      performance = FactoryBot.create :performance, match: match, player: player
      delete performance_url(performance)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      performance = FactoryBot.create :performance
      delete performance_url(performance),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Performance' do
      performance = FactoryBot.create :performance, match: match, player: player
      delete performance_url(performance),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { performance.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
