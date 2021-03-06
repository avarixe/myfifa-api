require 'rails_helper'

RSpec.describe SquadsController, type: :request do
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
      get team_squads_url(team)
      assert_response 401
    end

    it 'returns all Squads of select Team' do
      FactoryBot.create_list :squad, 3, team: team
      FactoryBot.create :squad

      get team_squads_url(team),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(team.squads.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      squad = FactoryBot.create :squad, team: team
      get squad_url(squad)
      assert_response 401
    end

    it 'returns Squad JSON' do
      squad = FactoryBot.create :squad, team: team
      get squad_url(squad),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(squad.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        squad_params = FactoryBot.attributes_for(:squad, team: team)
        squad_params[:squad_players_attributes] = []

        positions = Cap::POSITIONS.sample(11)
        11.times do |i|
          player = FactoryBot.create :player, team: team
          squad_params[:squad_players_attributes] << FactoryBot.attributes_for(
            :squad_player,
            player_id: player.id,
            pos: positions[i],
            squad: nil
          ).except(:squad)
        end

        post team_squads_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { squad: squad_params }
      end
    end

    it 'requires a valid token', skip_before: true do
      post team_squads_url(team),
           params: { squad: FactoryBot.attributes_for(:squad, team: team) }
      assert_response 401
    end

    it 'creates a new Squad' do
      expect(Squad.count).to be == 1
    end

    it 'returns Squad JSON' do
      squad = Squad.last
      expect(json).to be == JSON.parse(squad.to_json)
    end
  end

  describe 'PATCH #update' do
    before :each do |test|
      @squad = FactoryBot.create :squad, team: team
      @squad_params = FactoryBot.attributes_for(:squad, team: team)
      @squad_params[:squad_players_attributes] = []

      positions = Cap::POSITIONS.sample(11)
      @squad.squad_players.each_with_index do |item, i|
        player = FactoryBot.create :player, team: team
        @squad_params[:squad_players_attributes] << FactoryBot.attributes_for(
          :squad_player,
          player_id: player.id,
          pos: positions[i],
          squad: nil
        ).except(:squad).merge(id: item.id)
      end
    end

    it 'requires a valid token' do
      patch squad_url(@squad),
            params: { squad: @squad_params }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      squad = FactoryBot.create :squad
      patch squad_url(squad),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { squad: @squad_params }
      assert_response 403
    end

    it 'returns updated Squad JSON' do
      patch squad_url(@squad),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { squad: @squad_params }
      expect(json).to be == JSON.parse(@squad.reload.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      squad = FactoryBot.create :squad, team: team
      delete squad_url(squad)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      squad = FactoryBot.create :squad
      delete squad_url(squad),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Squad' do
      squad = FactoryBot.create :squad, team: team
      delete squad_url(squad),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { squad.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe 'POST #store_lineup' do
    let(:game) { FactoryBot.create(:match, team: team) }
    let(:squad) { FactoryBot.create(:squad, team: team) }

    before do
      11.times do |i|
        player = FactoryBot.create :player, team: game.team
        FactoryBot.create :cap, match: game, player: player, start: 0, pos: Cap::POSITIONS[i]
      end
    end

    it 'requires a valid token' do
      post store_lineup_squad_path(squad, game)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      other_squad = FactoryBot.create :squad
      post store_lineup_squad_path(other_squad, game),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'returns updated Match Performances JSON' do
      post store_lineup_squad_path(squad, game),
           headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(squad.reload.to_json)
    end
  end
end
