# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::UpdateSquad, type: :graphql do
  subject { described_class }

  let(:squad) { create :squad }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('SquadAttributes!') }
  it { is_expected.to have_a_field(:squad).returning('Squad') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateSquad($id: ID!, $attributes: SquadAttributes!) {
      updateSquad(id: $id, attributes: $attributes) {
        squad { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: squad.id,
      attributes: graphql_attributes_for(:squad).merge(
        squadPlayersAttributes: squad.squad_players.map do |squad_player|
          {
            id: squad_player.id,
            playerId: squad_player.player_id,
            pos: Cap::POSITIONS[Cap::POSITIONS.index(squad_player.pos) - 1]
          }
        end
      )
    }
  end

  graphql_context do
    { current_user: squad.team.user }
  end

  it 'updates the Squad' do
    old_attributes = squad.attributes
    execute_graphql
    expect(squad.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Squad' do
    expect(response_data.dig('updateSquad', 'squad', 'id'))
      .to be == squad.id.to_s
  end
end
