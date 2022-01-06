# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UploadBadge, type: :request do
  subject { described_class }

  let(:user) { create :user }
  let(:team) { create :team, user: user }
  let(:test_badge) do
    test_badge_path = Rails.root.join('spec/support/test-badge.png')
    Rack::Test::UploadedFile.new test_badge_path, 'image/png'
  end
  let(:params) do
    query = <<-GQL
      mutation uploadBadge($teamId: ID!, $badge: Upload!) {
        uploadBadge(teamId: $teamId, badge: $badge) {
          team { badgePath }
          errors { fullMessages }
        }
      }
    GQL
    {
      query: query,
      variables: { teamId: team.id, badge: nil }.to_json,
      operations: {
        query: query,
        operationName: 'uploadBadge',
        variables: { teamId: team.id, badge: test_badge }
      }.to_json,
      map: { '1': ['variables.badge'] }.to_json,
      '1': test_badge
    }
  end

  it { is_expected.to accept_argument(:team_id).of_type('ID!') }
  it { is_expected.to accept_argument(:badge).of_type('Upload!') }
  it { is_expected.to have_a_field(:team).returning('Team') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  describe 'when execution' do
    before do
      token = create :access_token, user: user
      post graphql_url,
           headers: { 'Authorization' => "Bearer #{token.token}" },
           params: params
    end

    it 'uploads the Team Badge' do
      expect(team.reload.badge.attached?).to be true
    end

    it 'returns the updated Team' do
      badge_path = json.dig('data', 'uploadBadge', 'team', 'badgePath')
      expect(badge_path).to be == team.reload.badge_path
    end
  end
end
