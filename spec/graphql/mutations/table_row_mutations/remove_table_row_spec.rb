# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TableRowMutations::RemoveTableRow, type: :graphql do
  let(:table_row) { create(:table_row) }
  let!(:user) { table_row.team.user }

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
    { current_user: user }
  end

  it 'removes the TableRow' do
    execute_graphql
    expect { table_row.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed TableRow' do
    expect(response_data.dig('removeTableRow', 'tableRow', 'id'))
      .to eq table_row.id.to_s
  end
end
