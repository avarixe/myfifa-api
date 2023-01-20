# frozen_string_literal: true

require 'rails_helper'

describe Mutations::LoanMutations::AddLoan, type: :graphql do
  subject { described_class }

  let(:player) { create(:player) }

  it { is_expected.to accept_argument(:player_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('LoanAttributes!') }
  it { is_expected.to have_a_field(:loan).returning('Loan') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addLoan($playerId: ID!, $attributes: LoanAttributes!) {
      addLoan(playerId: $playerId, attributes: $attributes) {
        loan { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      playerId: player.id,
      attributes: graphql_attributes_for(:loan).merge(
        signedOn: player.team.currently_on.to_s,
        startedOn: player.team.currently_on.to_s,
        endedOn: (player.team.currently_on + 1.year).to_s
      )
    }
  end

  graphql_context do
    { current_user: player.team.user }
  end

  it 'creates a Loan for the Player' do
    record_id = response_data.dig('addLoan', 'loan', 'id')
    expect(player.reload.loans.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Loan' do
    expect(response_data.dig('addLoan', 'loan', 'id'))
      .to be_present
  end
end
