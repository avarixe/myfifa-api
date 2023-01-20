# frozen_string_literal: true

require 'rails_helper'

describe Mutations::ContractMutations::UpdateContract, type: :graphql do
  subject { described_class }

  let(:contract) { create(:contract) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('ContractAttributes!') }
  it { is_expected.to have_a_field(:contract).returning('Contract') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateContract($id: ID!, $attributes: ContractAttributes!) {
      updateContract(id: $id, attributes: $attributes) {
        contract { id }
        errors { fullMessages }
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
    { current_user: contract.team.user }
  end

  it 'updates the Contract' do
    old_attributes = contract.attributes
    execute_graphql
    expect(contract.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Contract' do
    expect(response_data.dig('updateContract', 'contract', 'id'))
      .to be == contract.id.to_s
  end
end
