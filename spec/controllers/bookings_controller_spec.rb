require 'rails_helper'

RSpec.describe BookingsController, type: :request do
  let(:user) { FactoryBot.create(:user) }
  let(:team) { FactoryBot.create(:team_with_players, user: user) }
  let(:player) { FactoryBot.create(:player, team: team) }
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
      get match_bookings_url(match)
      assert_response 401
    end

    it 'returns all Bookings of select Match' do
      FactoryBot.create_list :booking, 3, match: match

      FactoryBot.create :booking

      get match_bookings_url(match),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(json).to be == JSON.parse(match.bookings.to_json)
    end
  end

  describe 'GET #show' do
    it 'requires a valid token' do
      booking = FactoryBot.create :booking, match: match
      get booking_url(booking)
      assert_response 401
    end

    it 'returns Booking JSON' do
      booking = FactoryBot.create :booking, match: match
      get booking_url(booking),
          headers: { 'Authorization' => "Bearer #{token.token}" }
      expect(json).to be == JSON.parse(booking.to_json)
    end
  end

  describe 'POST #create' do
    before :each do |test|
      unless test.metadata[:skip_before]
        post match_bookings_url(match),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { booking: FactoryBot.attributes_for(:booking, player_id: player.id) }
      end
    end

    it 'requires a valid token', skip_before: true do
      post match_bookings_url(match),
           params: { booking: FactoryBot.attributes_for(:booking, player_id: player.id) }
      assert_response 401
    end

    it 'creates a new Booking' do
      expect(Booking.count).to be == 1
    end

    it 'returns Match JSON' do
      expect(json).to be == JSON.parse(match.to_json(methods: %i[events performances]))
    end
  end

  describe 'PATCH #update' do
    it 'requires a valid token' do
      booking = FactoryBot.create :booking, match: match
      patch booking_url(booking),
            params: { booking: FactoryBot.attributes_for(:booking) }
      assert_response 401
    end
    
    it 'rejects requests from other Users' do
      booking = FactoryBot.create :booking
      patch booking_url(booking),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { booking: FactoryBot.attributes_for(:booking) }
      assert_response 403
    end

    it 'returns updated Match JSON' do
      booking = FactoryBot.create :booking, match: match
      patch booking_url(booking),
            headers: { 'Authorization' => "Bearer #{token.token}" },
            params: { booking: FactoryBot.attributes_for(:booking) }
      expect(json).to be == JSON.parse(match.to_json(methods: %i[events performances]))
    end
  end

  describe 'DELETE #destroy' do
    it 'requires a valid token' do
      booking = FactoryBot.create :booking, match: match
      delete booking_url(booking)
      assert_response 401
    end

    it 'rejects requests from other Users' do
      booking = FactoryBot.create :booking
      delete booking_url(booking),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response 403
    end

    it 'removes Booking' do
      booking = FactoryBot.create :booking, match: match
      delete booking_url(booking),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      expect { booking.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
