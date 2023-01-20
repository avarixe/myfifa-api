# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::AddCap, type: :graphql do
  subject { described_class }

  let(:match) { create(:match) }

  it { is_expected.to accept_argument(:match_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('CapAttributes!') }
  it { is_expected.to have_a_field(:cap).returning('Cap') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addCap($matchId: ID!, $attributes: CapAttributes!) {
      addCap(matchId: $matchId, attributes: $attributes) {
        cap { id }
        errors { fullMessages }
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
