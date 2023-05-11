# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::UpdatePlayer, type: :graphql do
  let(:player) { create(:player) }
  let!(:user) { player.team.user }

  graphql_operation "
    mutation updatePlayer($id: ID!, $attributes: PlayerAttributes!) {
      updatePlayer(id: $id, attributes: $attributes) {
        player { id }
      }
    }
  "

  graphql_variables do
    {
      id: player.id,
      attributes: graphql_attributes_for(:player).except('birthYear').merge(
        age: Faker::Number.between(from: 18, to: 30).to_i
      )
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Player' do
    old_attributes = player.attributes
    execute_graphql
    expect(player.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Player' do
    expect(response_data.dig('updatePlayer', 'player', 'id'))
      .to be == player.id.to_s
  end
end
