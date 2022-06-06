# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::AddPlayer, type: :graphql do
  subject { described_class }

  let(:team) { create :team }

  it { is_expected.to accept_argument(:team_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('PlayerAttributes!') }
  it { is_expected.to have_a_field(:player).returning('Player') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addPlayer($teamId: ID!, $attributes: PlayerAttributes!) {
      addPlayer(teamId: $teamId, attributes: $attributes) {
        player { id }
        errors { fullMessages }
      }
    }
  "

  graphql_context do
    { current_user: team.team.user }
  end

  describe 'with valid attributes' do
    graphql_variables do
      {
        teamId: team.id,
        attributes: graphql_attributes_for(:player).except('birthYear').merge(
          age: Faker::Number.between(from: 18, to: 30).to_i
        )
      }
    end

    it 'creates a Player for the Team' do
      record_id = response_data.dig('addPlayer', 'player', 'id')
      expect(team.reload.players.pluck(:id))
        .to include record_id.to_i
    end

    it 'returns the created Player' do
      expect(response_data.dig('addPlayer', 'player', 'id'))
        .to be_present
    end
  end

  describe 'with invalid attributes' do
    graphql_variables do
      {
        teamId: team.id,
        attributes: { name: Faker::Team.name }
      }
    end

    it 'does not create a Player' do
      execute_graphql
      expect(Player.count).to be_zero
    end

    it 'returns an error message' do
      execute_graphql
      expect(response_data.dig('addPlayer', 'errors')).to be_present
    end
  end
end
