# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::RemoveContract, type: :graphql do
  let(:contract) { create(:contract) }
  let!(:user) { contract.team.user }

  graphql_operation "
    mutation removeContract($id: ID!) {
      removeContract(id: $id) {
        contract { id }
      }
    }
  "

  graphql_variables do
    { id: contract.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Contract' do
    execute_graphql
    expect { contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Contract' do
    expect(response_data.dig('removeContract', 'contract', 'id'))
      .to eq contract.id.to_s
  end
end
