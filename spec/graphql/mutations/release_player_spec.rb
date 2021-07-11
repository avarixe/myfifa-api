# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ReleasePlayer do
  subject { described_class }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:player).returning('Player!') }

  describe 'execution', type: :graphql do
    let(:user) { create :user }
    let(:player) do
      team = create :team, user: user
      create :player, team: team
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
      player = create :player
      execute_graphql
      expect(player.last_contract.conclusion).not_to be == 'Released'
    end
  end
end
