# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TransferMutations::RemoveTransfer, type: :graphql do
  let(:transfer) { create(:transfer) }
  let!(:user) { transfer.team.user }

  graphql_operation "
    mutation removeTransfer($id: ID!) {
      removeTransfer(id: $id) {
        transfer { id }
      }
    }
  "

  graphql_variables do
    { id: transfer.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Transfer' do
    execute_graphql
    expect { transfer.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Transfer' do
    expect(response_data.dig('removeTransfer', 'transfer', 'id'))
      .to eq transfer.id.to_s
  end
end
