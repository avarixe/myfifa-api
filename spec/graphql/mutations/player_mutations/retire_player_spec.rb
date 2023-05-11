# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::RetirePlayer, type: :graphql do
  let(:player) { create(:player) }
  let!(:user) { player.team.user }

  graphql_operation <<-GQL
    mutation retirePlayer($id: ID!) {
      retirePlayer(id: $id) {
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

  it 'updates the Player contract as Retiring' do
    execute_graphql
    expect(player.last_contract.conclusion).to be == 'Retired'
  end

  it 'returns the affected Player' do
    expect(response_data.dig('retirePlayer', 'player', 'id'))
      .to be == player.id.to_s
  end

  it 'does not release a Player not owned by user' do
    allow(Player).to receive(:find).and_return(player)
    allow(player).to receive(:team).and_return(player.team)
    allow(player.team).to receive(:user).and_return(create(:user))
    execute_graphql
    expect(player.last_contract.conclusion).not_to be == 'Retired'
  end
end
