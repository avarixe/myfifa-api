# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TransferMutations::AddTransfer, type: :graphql do
  subject { described_class }

  let(:player) { create(:player) }

  it { is_expected.to accept_argument(:player_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('TransferAttributes!') }
  it { is_expected.to have_a_field(:transfer).returning('Transfer!') }

  graphql_operation "
    mutation addTransfer($playerId: ID!, $attributes: TransferAttributes!) {
      addTransfer(playerId: $playerId, attributes: $attributes) {
        transfer { id }
      }
    }
  "

  graphql_variables do
    {
      playerId: player.id,
      attributes: graphql_attributes_for(:transfer).merge(
        signedOn: player.team.currently_on.to_s
      )
    }
  end

  graphql_context do
    { current_user: player.team.user }
  end

  it 'creates a Transfer for the Player' do
    record_id = response_data.dig('addTransfer', 'transfer', 'id')
    expect(player.reload.transfers.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Transfer' do
    expect(response_data.dig('addTransfer', 'transfer', 'id'))
      .to be_present
  end
end
