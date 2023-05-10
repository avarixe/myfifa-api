# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::UpdateCap, type: :graphql do
  let(:cap) { create(:cap) }

  graphql_operation "
    mutation updateCap($id: ID!, $attributes: CapAttributes!) {
      updateCap(id: $id, attributes: $attributes) {
        cap { id }
      }
    }
  "

  graphql_variables do
    {
      id: cap.id,
      attributes: {
        playerId: cap.player_id,
        pos: Cap::POSITIONS[Cap::POSITIONS.index(cap.pos) - 1]
      }
    }
  end

  graphql_context do
    { current_user: cap.team.user }
  end

  it 'updates the Cap' do
    old_attributes = cap.attributes
    execute_graphql
    expect(cap.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Cap' do
    expect(response_data.dig('updateCap', 'cap', 'id'))
      .to be == cap.id.to_s
  end
end
