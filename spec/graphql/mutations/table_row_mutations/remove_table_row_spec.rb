# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TableRowMutations::RemoveTableRow, type: :graphql do
  subject { described_class }

  let(:table_row) { create(:table_row) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:table_row).returning('TableRow!') }

  graphql_operation "
    mutation removeTableRow($id: ID!) {
      removeTableRow(id: $id) {
        tableRow { id }
      }
    }
  "

  graphql_variables do
    { id: table_row.id }
  end

  graphql_context do
    { current_user: table_row.team.user }
  end

  it 'removes the TableRow' do
    execute_graphql
    expect { table_row.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed TableRow' do
    expect(response_data.dig('removeTableRow', 'tableRow', 'id'))
      .to be == table_row.id.to_s
  end
end
