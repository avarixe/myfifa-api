# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::UpdateCap, type: :graphql do
  subject { described_class }

  let(:cap) { create :cap }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('CapAttributes!') }
  it { is_expected.to have_a_field(:cap).returning('Cap') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateCap($id: ID!, $attributes: CapAttributes!) {
      updateCap(id: $id, attributes: $attributes) {
        cap { id }
        errors { fullMessages }
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
