# frozen_string_literal: true

require 'rails_helper'

describe Mutations::LoanMutations::RemoveLoan, type: :graphql do
  let(:loan) { create(:loan) }
  let!(:user) { loan.team.user }

  graphql_operation "
    mutation removeLoan($id: ID!) {
      removeLoan(id: $id) {
        loan { id }
      }
    }
  "

  graphql_variables do
    { id: loan.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Loan' do
    execute_graphql
    expect { loan.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Loan' do
    expect(response_data.dig('removeLoan', 'loan', 'id'))
      .to eq loan.id.to_s
  end
end
