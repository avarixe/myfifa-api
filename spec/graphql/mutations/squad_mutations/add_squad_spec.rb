# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::AddSquad, type: :graphql do
  subject { described_class }

  let(:team) { create(:team) }

  it { is_expected.to accept_argument(:team_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('SquadAttributes!') }
  it { is_expected.to have_a_field(:squad).returning('Squad') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addSquad($teamId: ID!, $attributes: SquadAttributes!) {
      addSquad(teamId: $teamId, attributes: $attributes) {
        squad { id }
        errors { fullMessages }
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
    { current_user: team.team.user }
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
