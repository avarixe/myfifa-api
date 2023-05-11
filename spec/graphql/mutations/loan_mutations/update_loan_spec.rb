# frozen_string_literal: true

require 'rails_helper'

describe Mutations::LoanMutations::UpdateLoan, type: :graphql do
  let(:loan) { create(:loan) }
  let!(:user) { loan.team.user }

  graphql_operation "
    mutation updateLoan($id: ID!, $attributes: LoanAttributes!) {
      updateLoan(id: $id, attributes: $attributes) {
        loan { id }
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
    { current_user: user }
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
