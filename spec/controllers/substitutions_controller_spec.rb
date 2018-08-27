require 'rails_helper'

RSpec.describe SubstitutionsController, type: :request do
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
    it 'requires a valid token'
    it 'returns all Substitutions of select Match'
  end

  describe 'GET #show' do
    it 'requires a valid token'
    it 'returns Substitution JSON'
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
      end
    end

    it 'requires a valid token', skip_before: true
    it 'creates a new Substitution'
    it 'returns Match JSON'
  end

  describe 'PATCH #update' do
    it 'requires a valid token'
    it 'rejects requests from other Users'
    it 'returns updated Match JSON'
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token'
    it 'rejects requests from other Users'
    it 'removes Substitution'
  end
end
