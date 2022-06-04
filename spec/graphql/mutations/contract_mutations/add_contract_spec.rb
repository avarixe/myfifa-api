# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::AddContract, type: :graphql do
  subject { described_class }

  let(:player) { create :player }

  it { is_expected.to accept_argument(:player_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('ContractAttributes!') }
  it { is_expected.to have_a_field(:contract).returning('Contract') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addContract($playerId: ID!, $attributes: ContractAttributes!) {
      addContract(playerId: $playerId, attributes: $attributes) {
        contract { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      playerId: player.id,
      attributes: graphql_attributes_for(:contract).merge(
        signedOn: player.team.currently_on.to_s
      )
    }
  end

  graphql_context do
    { current_user: player.team.user }
  end

  it 'creates a Contract for the Player' do
    record_id = response_data.dig('addContract', 'contract', 'id')
    expect(player.reload.contracts.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Contract' do
    expect(response_data.dig('addContract', 'contract', 'id'))
      .to be_present
  end
end
