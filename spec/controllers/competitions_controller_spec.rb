# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompetitionsController, type: :request do
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
      get team_competitions_url(team)
      assert_response 401
    end

    it 'returns all Competitions of select Team' do
      FactoryBot.create_list :competition, 10, team: team
      FactoryBot.create :competition

      get team_competitions_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(team.competitions.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      competition = FactoryBot.create :competition, team: team
      get competition_url(competition)
      assert_response 401
    end

    it 'returns Competition JSON' do
      competition = FactoryBot.create :competition, team: team
      get competition_url(competition),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(competition.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post team_competitions_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { competition: FactoryBot.attributes_for(:competition) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post team_competitions_url(team),
           params: { competition: FactoryBot.attributes_for(:competition) }
      assert_response 401
    end

    it 'creates a new Competition' do
      expect(Competition.count).to be == 1
    end

    it 'returns Competition JSON' do
      competition = Competition.last
      expect(json).to be == JSON.parse(competition.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      competition = FactoryBot.create :competition, team: team
      patch competition_url(competition),
            params: { competition: FactoryBot.attributes_for(:competition) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      competition = FactoryBot.create :competition
      patch competition_url(competition),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { competition: FactoryBot.attributes_for(:competition) }
      assert_response 403
    end

    it 'returns updated Competition JSON' do
      competition = FactoryBot.create :competition, team: team
      patch competition_url(competition),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { competition: FactoryBot.attributes_for(:competition) }
      expect(json).to be == JSON.parse(competition.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      competition = FactoryBot.create :competition, team: team
      delete competition_url(competition)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      competition = FactoryBot.create :competition
      delete competition_url(competition),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Competition' do
      competition = FactoryBot.create :competition, team: team
      delete competition_url(competition),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { competition.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
