# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::AddPlayer, type: :graphql do
  let(:team) { create(:team) }
  let!(:user) { team.user }

  graphql_operation "
    mutation addPlayer($teamId: ID!, $attributes: PlayerAttributes!) {
      addPlayer(teamId: $teamId, attributes: $attributes) {
        player { id }
      }
    }
  "

  graphql_context do
    { current_user: user }
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

    it 'does not create a Player if Team is not owned by User' do
      allow(team).to receive(:user).and_return(create(:user))
      allow(Team).to receive(:find).and_return(team)
      execute_graphql
      expect(response['errors']).to be_present
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
      expect(response['errors']).to be_present
    end
  end
end
