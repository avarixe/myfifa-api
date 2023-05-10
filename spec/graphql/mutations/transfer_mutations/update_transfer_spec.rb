# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TransferMutations::UpdateTransfer, type: :graphql do
  let(:transfer) { create(:transfer) }

  graphql_operation "
    mutation updateTransfer($id: ID!, $attributes: TransferAttributes!) {
      updateTransfer(id: $id, attributes: $attributes) {
        transfer { id }
      }
    }
  "

  graphql_variables do
    {
      id: transfer.id,
      attributes: graphql_attributes_for(:transfer).merge(
        signedOn: transfer.team.currently_on.to_s
      )
    }
  end

  graphql_context do
    { current_user: transfer.team.user }
  end

  it 'updates the Transfer' do
    old_attributes = transfer.attributes
    execute_graphql
    expect(transfer.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Transfer' do
    expect(response_data.dig('updateTransfer', 'transfer', 'id'))
      .to be == transfer.id.to_s
  end
end
