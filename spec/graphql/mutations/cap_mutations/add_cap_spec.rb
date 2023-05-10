# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::AddCap, type: :graphql do
  let(:match) { create(:match) }

  graphql_operation "
    mutation addCap($matchId: ID!, $attributes: CapAttributes!) {
      addCap(matchId: $matchId, attributes: $attributes) {
        cap { id }
      }
    }
  "

  graphql_variables do
    {
      matchId: match.id,
      attributes: {
        playerId: create(:player, team: match.team).id,
        pos: Cap::POSITIONS.sample
      }
    }
  end

  graphql_context do
    { current_user: match.team.user }
  end

  it 'creates a Cap for the Match' do
    record_id = response_data.dig('addCap', 'cap', 'id')
    expect(match.reload.caps.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Cap' do
    expect(response_data.dig('addCap', 'cap', 'id'))
      .to be_present
  end
end
