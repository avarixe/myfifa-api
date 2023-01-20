# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TransferMutations::RemoveTransfer, type: :graphql do
  subject { described_class }

  let(:transfer) { create(:transfer) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:transfer).returning('Transfer') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeTransfer($id: ID!) {
      removeTransfer(id: $id) {
        transfer { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: transfer.id }
  end

  graphql_context do
    { current_user: transfer.team.user }
  end

  it 'removes the Transfer' do
    execute_graphql
    expect { transfer.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Transfer' do
    expect(response_data.dig('removeTransfer', 'transfer', 'id'))
      .to be == transfer.id.to_s
  end
end
