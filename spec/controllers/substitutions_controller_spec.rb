require 'rails_helper'

RSpec.describe SubstitutionsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team_with_players, user: user) }
  let(:player1) { FactoryBot.create(:player, team: team) }
  let(:player2) { FactoryBot.create(:player, team: team) }
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

  describe 'GET #index' do
    it 'requires a valid token' do
      get match_substitutions_url(match)
      assert_response 401
    end

    it 'returns all Substitutions of select Match' do
      3.times do
        player1 = FactoryBot.create :player, team: team
        player2 = FactoryBot.create :player, team: team
        FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      end

      FactoryBot.create :substitution

      get match_substitutions_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(match.substitutions.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      get substitution_url(substitution)
      assert_response 401
    end

    it 'returns Substitution JSON' do
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      get substitution_url(substitution),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(substitution.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        post match_substitutions_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { substitution: FactoryBot.attributes_for(:substitution, player_id: player1.id, replacement_id: player2.id) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_substitutions_url(match),
           params: { substitution: FactoryBot.attributes_for(:substitution, player_id: player1.id, replacement_id: player2.id) }
      assert_response 401
    end

    it 'creates a new Substitution' do
      expect(Substitution.count).to be == 1
    end

    it 'returns Match JSON' do
      expect(json).to be == JSON.parse(match.reload.to_json(methods: %i[events performances]))
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      patch substitution_url(substitution),
            params: { substitution: FactoryBot.attributes_for(:substitution) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      substitution = FactoryBot.create :substitution
      patch substitution_url(substitution),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { substitution: FactoryBot.attributes_for(:substitution) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      patch substitution_url(substitution),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { substitution: FactoryBot.attributes_for(:substitution) }
      expect(json).to be == JSON.parse(match.reload.to_json(methods: %i[events performances]))
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      delete substitution_url(substitution)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      substitution = FactoryBot.create :substitution
      delete substitution_url(substitution),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Substitution' do
      FactoryBot.create :performance, match: match, player: player1
      substitution = FactoryBot.create :substitution, match: match, player: player1, replacement: player2
      delete substitution_url(substitution),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { substitution.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
