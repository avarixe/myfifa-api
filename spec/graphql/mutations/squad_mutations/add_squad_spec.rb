# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::AddSquad, type: :graphql do
  let(:team) { create(:team) }
  let!(:user) { team.user }

  graphql_operation "
    mutation addSquad($teamId: ID!, $attributes: SquadAttributes!) {
      addSquad(teamId: $teamId, attributes: $attributes) {
        squad { id }
      }
    }
  "

  graphql_variables do
    {
      teamId: team.id,
      attributes: {
        name: Faker::Team.name,
        squadPlayersAttributes: (0...11).map do |i|
          {
            playerId: create(:player, team:).id,
            pos: Cap::POSITIONS[i]
          }
        end
      }
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'creates a Squad for the Team' do
    record_id = response_data.dig('addSquad', 'squad', 'id')
    expect(team.reload.squads.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Squad' do
    expect(response_data.dig('addSquad', 'squad', 'id'))
      .to be_present
  end
end
