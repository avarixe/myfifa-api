require 'rails_helper'

RSpec.describe LoansController, type: :request do
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

  describe 'GET #index' do
    it 'requires a valid token' do
      get player_loans_url(player)
      assert_response 401
    end

    it 'returns all Loans of select Player' do
      10.times do
        loan = FactoryBot.create :loan, player: player
        loan.update(returned: true)
      end

      another_player = FactoryBot.create :player, team: team
      FactoryBot.create :loan, player: another_player

      get player_loans_url(player),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(player.loans.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      loan = FactoryBot.create :loan, player: player
      get loan_url(loan)
      assert_response 401
    end

    it 'returns Loan JSON' do
      loan = FactoryBot.create :loan, player: player

      get loan_url(loan),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(loan.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        post player_loans_url(player),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { loan: FactoryBot.attributes_for(:loan) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post player_loans_url(player),
           params: { team: FactoryBot.attributes_for(:player) }
      assert_response 401
    end

    it 'creates a new Loan' do
      expect(Loan.count).to be == 1
    end

    it 'returns Player JSON' do
      player.reload
      expect(json).to be == JSON.parse(player.to_json)
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      @loan = FactoryBot.create :loan, player: player
      patch loan_url(@loan),
            params: { loan: FactoryBot.attributes_for(:loan) }
      assert_response 401
    end

    it 'rejects requests from other Users' do
      @loan = FactoryBot.create :loan
      patch loan_url(@loan),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { loan: FactoryBot.attributes_for(:loan) }
      assert_response 403
    end

    it 'returns updated Player JSON' do
      @loan = FactoryBot.create :loan, player: player
      patch loan_url(@loan),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { loan: FactoryBot.attributes_for(:loan) }
      @loan.reload
      expect(json).to be == JSON.parse(player.to_json)
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      @loan = FactoryBot.create :loan, player: player
      delete loan_url(@loan)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      @loan = FactoryBot.create :loan
      delete loan_url(@loan),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes the Player' do
      @loan = FactoryBot.create :loan, player: player
      delete loan_url(@loan),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { @loan.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
