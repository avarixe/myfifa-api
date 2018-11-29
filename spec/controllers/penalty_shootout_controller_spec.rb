# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PenaltyShootoutController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team_with_players, user: user) }
  let(:match) { FactoryBot.create(:match, team: team) }
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

  before do
    Faker::UniqueGenerator.clear
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      FactoryBot.create :penalty_shootout, match: match
      get match_penalty_shootout_url(match)
      assert_response 401
    end

    it 'returns Penalty Shootout JSON' do
      ps = FactoryBot.create :penalty_shootout, match: match
      get match_penalty_shootout_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(ps.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post match_penalty_shootout_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { penalty_shootout: FactoryBot.attributes_for(:penalty_shootout) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_penalty_shootout_url(match),
           params: { penalty_shootout: FactoryBot.attributes_for(:penalty_shootout) }
      assert_response 401
    end

    it 'creates a new Penalty Shootout' do
      expect(PenaltyShootout.count).to be == 1
    end

    it 'returns Penalty Shootout JSON' do
      expect(json).to be == PenaltyShootout.last.as_json
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      ps = FactoryBot.create :penalty_shootout, match: match
      patch match_penalty_shootout_url(match),
            params: { penalty_shootout: FactoryBot.attributes_for(:penalty_shootout) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      match = FactoryBot.create :match
      ps = FactoryBot.create :penalty_shootout, match: match
      patch match_penalty_shootout_url(match),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { penalty_shootout: FactoryBot.attributes_for(:penalty_shootout) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      ps = FactoryBot.create :penalty_shootout, match: match
      patch match_penalty_shootout_url(match),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { penalty_shootout: FactoryBot.attributes_for(:penalty_shootout) }
      expect(json).to be == ps.reload.as_json
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      ps = FactoryBot.create :penalty_shootout, match: match
      delete match_penalty_shootout_url(match)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      match = FactoryBot.create :match
      ps = FactoryBot.create :penalty_shootout, match: match
      delete match_penalty_shootout_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Penalty Shootout' do
      ps = FactoryBot.create :penalty_shootout, match: match
      delete match_penalty_shootout_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { ps.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
