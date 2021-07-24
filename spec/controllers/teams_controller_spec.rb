# frozen_string_literal: true

require 'rails_helper'

describe TeamsController, type: :request do
  let(:user) { create :user }
  let(:team) { create :team, user: user }
  let(:token) { create :access_token, user: user }
  let(:test_badge_path) { Rails.root.join('spec/support/test-badge.png') }
  let(:team_badge_params) do
    { badge: Rack::Test::UploadedFile.new(test_badge_path) }
  end

  describe 'POST teams#add_badge' do
    it 'requires a valid token' do
      post badge_team_url(team), params: { team: team_badge_params }
      assert_response :unauthorized
    end

    describe 'with authorized token' do
      before do
        post badge_team_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" },
             params: { team: team_badge_params }
      end

      it 'uploads the Team Badge' do
        expect(team.reload.badge.attached?).to be true
      end

      it 'returns the Team badge path' do
        assert_response :success
        expect(response.body).to be == team.reload.badge_path
      end
    end
  end

  describe 'DELETE teams#remove_badge' do
    it 'requires a valid token' do
      delete badge_team_url(team)
      assert_response :unauthorized
    end

    it 'removes the Team badge' do
      team.badge.attach io: File.open(test_badge_path),
                        filename: 'test.txt'
      delete badge_team_url(team),
             headers: { 'Authorization' => "Bearer #{token.token}" }
      assert_response :success
      expect(team.reload.badge.attached?).to be false
    end
  end
end
