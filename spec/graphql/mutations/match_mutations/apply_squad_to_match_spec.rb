# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::ApplySquadToMatch, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }
  let(:match) { create(:match, team:) }
  let(:squad) { create(:squad, team:) }

  graphql_operation <<-GQL
    mutation applySquadToMatch($matchId: ID!, $squadId: ID!) {
      applySquadToMatch(matchId: $matchId, squadId: $squadId) {
        match { id }
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
      .to be == squad.squad_players.pluck(:player_id)
  end

  it 'populates Match caps based on Squad positions' do
    execute_graphql
    expect(match.caps.pluck(:pos))
      .to be == squad.squad_players.pluck(:pos)
  end

  it 'returns the affected Squad' do
    expect(response_data.dig('applySquadToMatch', 'match', 'id'))
      .to be == match.id.to_s
  end
end
