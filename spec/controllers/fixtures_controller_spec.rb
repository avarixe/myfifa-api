require 'rails_helper'

RSpec.describe FixturesController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
  let(:competition) { FactoryBot.create(:competition, team: team) }
  let(:stage) { FactoryBot.create(:stage, competition: competition) }

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
      get stage_fixtures_url(stage)
      assert_response 401
    end

    it 'returns all Fixtures of select Stage' do
      FactoryBot.create_list :fixture, 3, stage: stage
      FactoryBot.create :fixture

      get stage_fixtures_url(stage),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(stage.fixtures.reload.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      fixture = FactoryBot.create :fixture, stage: stage
      get fixture_url(fixture)
      assert_response 401
    end

    it 'returns Fixture JSON' do
      fixture = FactoryBot.create :fixture, stage: stage

      get fixture_url(fixture),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(fixture.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        fixture_params = FactoryBot.attributes_for :completed_fixture,
                                                   legs_count: 0
        fixture_params[:legs_attributes] = [
          FactoryBot.attributes_for(:fixture_leg).except(:fixture)
        ]

        post stage_fixtures_url(stage),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { fixture: fixture_params }
      end
    end

    it 'requires a valid token', skip_before: true do
      post stage_fixtures_url(stage),
           params: { fixture: FactoryBot.attributes_for(:completed_fixture) }
      assert_response 401
    end

    it 'returns Fixture JSON' do
      expect(json).to be == JSON.parse(Fixture.last.to_json)
    end

    it 'creates nested attribute FixtureLegs' do
      expect(Fixture.last.legs.count).to be == 1
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token', skip_before: true do
      fixture = FactoryBot.create :fixture, stage: stage

      fixture_params = FactoryBot.attributes_for :completed_fixture,
                                                 legs_count: 0
      fixture_params[:legs_attributes] = []
      fixture.legs.each do |leg|
        fixture_params[:legs_attributes] << FactoryBot.attributes_for(:fixture_leg)
                                            .except(:fixture)
                                            .merge(id: leg.id)
      end

      patch fixture_url(fixture),
            params: { fixture: fixture_params }
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      fixture = FactoryBot.create :fixture
      patch fixture_url(fixture),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { fixture: FactoryBot.attributes_for(:completed_fixture) }
      assert_response 403
    end

    it 'returns updated Fixture JSON' do
      fixture = FactoryBot.create :fixture, stage: stage
      patch fixture_url(fixture),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { fixture: FactoryBot.attributes_for(:completed_fixture) }
      expect(json).to be == JSON.parse(fixture.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token', skip_before: true do
      fixture = FactoryBot.create :fixture, stage: stage
      delete fixture_url(fixture)
      assert_response 401
    end

    it 'rejects requests from other Users', skip_before: true do
      fixture = FactoryBot.create :fixture
      delete fixture_url(fixture),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Fixture' do
      fixture = FactoryBot.create :fixture, stage: stage
      delete fixture_url(fixture),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { fixture.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
