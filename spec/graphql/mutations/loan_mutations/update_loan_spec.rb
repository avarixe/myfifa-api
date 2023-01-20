# frozen_string_literal: true

require 'rails_helper'

describe Mutations::LoanMutations::UpdateLoan, type: :graphql do
  subject { described_class }

  let(:loan) { create(:loan) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('LoanAttributes!') }
  it { is_expected.to have_a_field(:loan).returning('Loan') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateLoan($id: ID!, $attributes: LoanAttributes!) {
      updateLoan(id: $id, attributes: $attributes) {
        loan { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: loan.id,
      attributes: graphql_attributes_for(:loan).merge(
        signedOn: loan.team.currently_on.to_s,
        startedOn: loan.team.currently_on.to_s,
        endedOn: (loan.team.currently_on + 1.year).to_s
      )
    }
  end

  graphql_context do
    { current_user: loan.team.user }
  end

  it 'updates the Loan' do
    old_attributes = loan.attributes
    execute_graphql
    expect(loan.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Loan' do
    expect(response_data.dig('updateLoan', 'loan', 'id'))
      .to be == loan.id.to_s
  end
end
