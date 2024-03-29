# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::StoreMatchLineupToSquad do
  describe 'execution', type: :graphql do
    let(:user) { create(:user) }
    let(:team) { create(:team, user:) }
    let(:match) { create(:match, team:) }
    let(:squad) { create(:squad, team:) }

    before do
      11.times do |i|
        player = create(:player, team:)
        create(:cap,
               match:,
               player:,
               start: 0,
               stop: 90,
               pos: Cap::POSITIONS[i])
      end
    end

    graphql_operation <<-GQL
      mutation storeMatchLineupToSquad($matchId: ID!, $squadId: ID!) {
        storeMatchLineupToSquad(matchId: $matchId, squadId: $squadId) {
          squad { id }
        }
      }
    GQL

    graphql_variables do
      {
        matchId: match.id,
        squadId: squad.id
      }
    end

    graphql_context do
      { current_user: user }
    end

    it 'populates Match caps based on Squad players' do
      execute_graphql
      expect(match.caps.pluck(:player_id))
        .to be == squad.reload.squad_players.pluck(:player_id)
    end

    it 'populates Match caps based on Squad positions' do
      execute_graphql
      expect(match.caps.pluck(:pos))
        .to be == squad.reload.squad_players.pluck(:pos)
    end

    it 'returns the affected Squad' do
      expect(response_data.dig('storeMatchLineupToSquad', 'squad', 'id'))
        .to be == squad.id.to_s
    end
  end
end
