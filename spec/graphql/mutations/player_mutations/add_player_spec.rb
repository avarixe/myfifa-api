# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PlayerMutations::AddPlayer, type: :graphql do
  subject { described_class }

  let(:team) { create :team }

  it { is_expected.to accept_argument(:team_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('PlayerAttributes!') }
  it { is_expected.to have_a_field(:player).returning('Player') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addPlayer($teamId: ID!, $attributes: PlayerAttributes!) {
      addPlayer(teamId: $teamId, attributes: $attributes) {
        player { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      teamId: team.id,
      attributes: graphql_attributes_for(:player).except('birthYear').merge(
        age: Faker::Number.between(from: 18, to: 30).to_i
      )
    }
  end

  graphql_context do
    { current_user: team.team.user }
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
end
