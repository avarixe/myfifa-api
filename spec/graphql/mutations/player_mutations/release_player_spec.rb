# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::ReleasePlayer, type: :graphql do
  let(:user) { create(:user) }
  let(:player) do
    team = create(:team, user:)
    create(:player, team:)
  end

  graphql_operation <<-GQL
    mutation releasePlayer($id: ID!) {
      releasePlayer(id: $id) {
        player { id }
      }
    }
  GQL

  graphql_variables do
    { id: player.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'terminates the Player contract' do
    execute_graphql
    expect(player.last_contract.conclusion).to be == 'Released'
  end

  it 'returns the affected Player' do
    expect(response_data.dig('releasePlayer', 'player', 'id'))
      .to be == player.id.to_s
  end

  it 'does not release a Player not owned by user' do
    player = create(:player)
    execute_graphql
    expect(player.last_contract.conclusion).not_to be == 'Released'
  end
end
