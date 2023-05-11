# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::AddContract, type: :graphql do
  let(:player) { create(:player) }
  let!(:user) { player.team.user }

  graphql_operation "
    mutation addContract($playerId: ID!, $attributes: ContractAttributes!) {
      addContract(playerId: $playerId, attributes: $attributes) {
        contract { id }
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
    { current_user: user }
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
