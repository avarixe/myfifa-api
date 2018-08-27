require 'rails_helper'

RSpec.describe TeamsController, type: :request do
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

  describe 'GET #index' do
    it 'requires a valid token' do
      get teams_url
      assert_response 401
    end

    it 'returns all User Teams' do
      another_user = FactoryBot.create :user, email: Faker::Internet.unique.email
      FactoryBot.create_list :team, 10, user: user
      FactoryBot.create :team, user: another_user

      get teams_url,
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(user.teams.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      team = FactoryBot.create :team, user: user
      get team_url(team)
      assert_response 401
    end

    it 'returns Team JSON' do
      team = FactoryBot.create :team, user: user

      get team_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(team.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        post teams_url,
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { team: FactoryBot.attributes_for(:team) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post teams_url,
           params: { team: FactoryBot.attributes_for(:team) }
      assert_response 401
    end

    it 'creates a new Team' do
      expect(Team.count).to be == 1
    end

    it 'returns Team JSON' do
      team = Team.last
      expect(json).to be == JSON.parse(team.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      @team = FactoryBot.create :team, user: user
      patch team_url(@team),
            params: { team: FactoryBot.attributes_for(:team) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      @team = FactoryBot.create :team
      patch team_url(@team),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { team: FactoryBot.attributes_for(:team) }
      assert_response 403
    end

    it 'returns updated Team JSON' do
      @team = FactoryBot.create :team, user: user
      patch team_url(@team),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { team: FactoryBot.attributes_for(:team) }
      @team.reload
      expect(json).to be == JSON.parse(@team.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      @team = FactoryBot.create :team, user: user
      delete team_url(@team)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      @team = FactoryBot.create :team
      delete team_url(@team),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Team' do
      @team = FactoryBot.create :team, user: user
      delete team_url(@team),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { @team.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
