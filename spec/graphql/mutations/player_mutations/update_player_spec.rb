# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::UpdatePlayer, type: :graphql do
  subject { described_class }

  let(:player) { create(:player) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('PlayerAttributes!') }
  it { is_expected.to have_a_field(:player).returning('Player!') }

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
    { current_user: player.team.user }
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
