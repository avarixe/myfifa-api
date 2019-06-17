# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GoalsController, type: :request do
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
      post team_goals_search_url(team)
      assert_response 401
    end

    it 'returns all Goals of select Team' do
      3.times do
        player = FactoryBot.create :player, team: team
        FactoryBot.create :goal, player: player
      end

      post team_goals_search_url(team),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      goals = Goal.where(player_id: team.players.pluck(:id))
      expect(json).to be == JSON.parse(goals.to_json)
    end

    it 'filters Goal results by filter params'
  end

  describe 'GET #index' do
    it 'requires a valid token' do
      get match_goals_url(match)
      assert_response 401
    end

    it 'returns all Goals of select Match' do
      FactoryBot.create_list :goal, 3, match: match
      FactoryBot.create :goal

      get match_goals_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(match.goals.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      goal = FactoryBot.create :away_goal, match: match
      get goal_url(goal)
      assert_response 401
    end

    it 'returns Goal JSON' do
      goal = FactoryBot.create :away_goal, match: match
      get goal_url(goal),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(goal.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post match_goals_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { goal: FactoryBot.attributes_for(:home_goal, player: player) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_goals_url(match),
           params: { goal: FactoryBot.attributes_for(:home_goal, player: player) }
      assert_response 401
    end

    it 'creates a new Goal' do
      expect(Goal.count).to be == 1
    end

    it 'returns Goal JSON' do
      expect(json).to be == Goal.last.as_json
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      goal = FactoryBot.create :goal, match: match
      patch goal_url(goal),
            params: { goal: FactoryBot.attributes_for(:away_goal) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      goal = FactoryBot.create :goal
      patch goal_url(goal),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { goal: FactoryBot.attributes_for(:away_goal) }
      assert_response 403
    end

    it 'returns updated Goal JSON' do
      goal = FactoryBot.create :goal, match: match
      patch goal_url(goal),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { goal: FactoryBot.attributes_for(:away_goal) }
      expect(json).to be == goal.reload.as_json
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      goal = FactoryBot.create :goal, match: match
      delete goal_url(goal)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      goal = FactoryBot.create :goal
      delete goal_url(goal),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Goal' do
      goal = FactoryBot.create :goal, match: match
      delete goal_url(goal),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { goal.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
