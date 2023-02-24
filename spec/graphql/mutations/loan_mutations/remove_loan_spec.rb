# frozen_string_literal: true

require 'rails_helper'

describe Mutations::LoanMutations::RemoveLoan, type: :graphql do
  subject { described_class }

  let(:loan) { create(:loan) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:loan).returning('Loan!') }

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
    { current_user: loan.team.user }
  end

  it 'removes the Loan' do
    execute_graphql
    expect { loan.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Loan' do
    expect(response_data.dig('removeLoan', 'loan', 'id'))
      .to be == loan.id.to_s
  end
end
