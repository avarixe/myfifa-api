require 'rails_helper'

RSpec.describe StagesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
  let(:competition) { FactoryBot.create(:competition, team: team) }
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

  describe 'GET #team_index' do
    it 'requires a valid token' do
      get team_stages_url(team)
      assert_response 401
    end

    it 'returns all Stages of select Team' do
      3.times do
        competition = FactoryBot.create :competition, team: team
        FactoryBot.create :stage, competition: competition
      end

      get team_stages_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      stages = Stage
               .includes(:table_rows, :fixtures)
               .where(competition_id: team.competitions.pluck(:id))
      expect(json).to be == JSON.parse(stages.to_json)
    end
  end

  describe 'GET #index' do
    it 'requires a valid token' do
      get competition_stages_url(competition)
      assert_response 401
    end

    it 'returns all Stages of select Competition' do
      FactoryBot.create_list :stage, 3, competition: competition
      FactoryBot.create :stage

      get competition_stages_url(competition),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      stages = competition.stages.includes(:table_rows, :fixtures)
      expect(json).to be == JSON.parse(stages.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      stage = FactoryBot.create :stage, competition: competition
      get stage_url(stage)
      assert_response 401
    end

    it 'returns Stage JSON' do
      stage = FactoryBot.create :stage, competition: competition

      get stage_url(stage),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(stage.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post competition_stages_url(competition),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { stage: FactoryBot.attributes_for(:stage) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post competition_stages_url(competition),
           params: { stage: FactoryBot.attributes_for(:stage) }
      assert_response 401
    end

    it 'creates a new Stage' do
      expect(Stage.count).to be == 1
    end

    it 'returns Stage JSON' do
      expect(json).to be == JSON.parse(Stage.last.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token', skip_before: true do
      stage = FactoryBot.create :stage, competition: competition
      patch stage_url(stage),
            params: { stage: FactoryBot.attributes_for(:stage) }
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      stage = FactoryBot.create :stage
      patch stage_url(stage),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { stage: FactoryBot.attributes_for(:stage) }
      assert_response 403
    end

    it 'returns updated Stage JSON' do
      stage = FactoryBot.create :stage, competition: competition
      patch stage_url(stage),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { stage: FactoryBot.attributes_for(:stage) }
      expect(json).to be == JSON.parse(stage.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token', skip_before: true do
      stage = FactoryBot.create :stage, competition: competition
      delete stage_url(stage)
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      stage = FactoryBot.create :stage
      delete stage_url(stage),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Stage' do
      stage = FactoryBot.create :stage, competition: competition
      delete stage_url(stage),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { stage.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
