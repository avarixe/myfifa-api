# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::RemovePlayer, type: :graphql do
  let(:player) { create(:player) }
  let!(:user) { player.team.user }

  graphql_operation "
    mutation removePlayer($id: ID!) {
      removePlayer(id: $id) {
        player { id }
      }
    }
  "

  graphql_variables do
    { id: player.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Player' do
    execute_graphql
    expect { player.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Player' do
    expect(response_data.dig('removePlayer', 'player', 'id'))
      .to be == player.id.to_s
  end
end
