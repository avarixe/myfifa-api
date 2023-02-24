# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::RemoveContract, type: :graphql do
  subject { described_class }

  let(:contract) { create(:contract) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:contract).returning('Contract!') }

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
    { current_user: contract.team.user }
  end

  it 'removes the Contract' do
    execute_graphql
    expect { contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Contract' do
    expect(response_data.dig('removeContract', 'contract', 'id'))
      .to be == contract.id.to_s
  end
end
