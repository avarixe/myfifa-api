# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::UpdateContract, type: :graphql do
  let(:contract) { create(:contract) }
  let!(:user) { contract.team.user }

  graphql_operation "
    mutation updateContract($id: ID!, $attributes: ContractAttributes!) {
      updateContract(id: $id, attributes: $attributes) {
        contract { id }
      }
    }
  "

  graphql_variables do
    {
      id: contract.id,
      attributes: graphql_attributes_for(:contract).merge(
        signedOn: contract.team.currently_on.to_s
      )
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Contract' do
    old_attributes = contract.attributes
    execute_graphql
    expect(contract.reload.attributes).not_to eq old_attributes
  end

  it 'returns the update Contract' do
    expect(response_data.dig('updateContract', 'contract', 'id'))
      .to eq contract.id.to_s
  end
end
