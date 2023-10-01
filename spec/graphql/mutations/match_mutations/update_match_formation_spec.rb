# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::UpdateMatch, type: :graphql do
  let(:match) { create(:match) }
  let(:player) { create(:player, team: match.team) }
  let!(:user) { match.team.user }
  let(:caps) do
    %w[GK CB CM ST].map do |pos|
      player = create(:player, team: match.team)
      create(:cap, match:, player:, pos:, start: 0, stop: 90)
    end
  end
  let(:formation) do
    [
      { id: caps[0].id, pos: 'GK', playerId: caps[0].player_id },
      { id: caps[1].id, pos: 'CB', playerId: create(:player, team: match.team).id },
      { id: caps[2].id, pos: 'CAM', playerId: caps[2].player_id },
      { id: caps[3].id, pos: 'CF', playerId: create(:player, team: match.team).id }
    ]
  end

  graphql_operation "
    mutation updateMatchFormation($id: ID!, $minute: Int!, $formation: [SquadPlayerAttributes!]!) {
      updateMatchFormation(id: $id, minute: $minute, formation: $formation) {
        match { id }
      }
    }
  "

  graphql_variables do
    {
      id: match.id,
      minute: 60,
      formation:
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'does not replace Caps with no pos/player changes' do
    execute_graphql
    expect(caps[0].reload.next_id).to be_blank
  end

  it 'creates a replacement Cap reflecting pos/player changes' do
    execute_graphql
    formation.drop(1).each_with_index do |cell, i|
      expected_cell = [cell[:pos], cell[:playerId]]
      new_cap = caps[i + 1].reload.next
      expect([new_cap.pos, new_cap.player_id]).to match_array(expected_cell)
    end
  end

  it 'does not replace existing replacement Caps' do
    cap2 = caps[1].create_next(
      match_id: match.id,
      player_id: caps[1].player_id,
      start: 70,
      pos: caps[1].pos
    )
    execute_graphql
    expect(caps[1].reload.next_id).to be == cap2.id
  end

  it 'returns the update Match' do
    expect(response_data.dig('updateMatchFormation', 'match', 'id'))
      .to be == match.id.to_s
  end
end
