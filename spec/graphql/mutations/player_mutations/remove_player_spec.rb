# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::RemovePlayer, type: :graphql do
  subject { described_class }

  let(:player) { create(:player) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:player).returning('Player') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removePlayer($id: ID!) {
      removePlayer(id: $id) {
        player { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: player.id }
  end

  graphql_context do
    { current_user: player.team.user }
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
