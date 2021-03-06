# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContractsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team, user: user) }
  let(:player) { FactoryBot.create(:player, team: team) }
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
      post team_contracts_search_url(team)
      assert_response 401
    end

    it 'returns all Contracts of select Team' do
      3.times do
        player = FactoryBot.create :player, team: team
        FactoryBot.create :contract, player: player
      end

      post team_contracts_search_url(team),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      contracts = Contract.where(player_id: team.players.pluck(:id))
      expect(json).to be == JSON.parse(contracts.to_json)
    end
  end

  describe 'GET #index' do
    it 'requires a valid token' do
      get player_contracts_url(player)
      assert_response 401
    end

    it 'returns all Contracts of select Player' do
      FactoryBot.create_list :contract, 3, player: player

      another_player = FactoryBot.create :player, team: team
      FactoryBot.create :contract, player: another_player

      get player_contracts_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(player.contracts.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      contract = FactoryBot.create(:contract, player: player)
      get contract_url(contract)
      assert_response 401
    end

    it 'returns Contract JSON' do
      contract = FactoryBot.create(:contract, player: player)

      get contract_url(contract),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(contract.to_json)
    end
  end

  describe 'POST #create' do
    before do |test|
      unless test.metadata[:skip_before]
        post player_contracts_url(player),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { contract: FactoryBot.attributes_for(:contract) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post player_contracts_url(player),
           params: { team: FactoryBot.attributes_for(:player) }
      assert_response 401
    end

    it 'creates a new Contract' do
      # expect 1 + default Contract from FactoryBot
      expect(Contract.count).to be == 2
    end

    it 'returns Contract JSON' do
      expect(json).to be == JSON.parse(Contract.last.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      contract = FactoryBot.create :contract, player: player
      patch contract_url(contract),
            params: { contract: FactoryBot.attributes_for(:contract) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      contract = FactoryBot.create :contract
      patch contract_url(contract),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { contract: FactoryBot.attributes_for(:contract) }
      assert_response 403
    end

    it 'returns updated Contract JSON' do
      contract = FactoryBot.create :contract, player: player
      patch contract_url(contract),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { contract: FactoryBot.attributes_for(:contract) }
      expect(json).to be == JSON.parse(contract.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      contract = FactoryBot.create :contract, player: player
      delete contract_url(contract)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      contract = FactoryBot.create :contract
      delete contract_url(contract),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Player' do
      contract = FactoryBot.create :contract, player: player
      delete contract_url(contract),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
