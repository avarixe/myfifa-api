# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TableRowMutations::UpdateTableRow, type: :graphql do
  let(:table_row) { create(:table_row) }
  let!(:user) { table_row.team.user }

  graphql_operation "
    mutation updateTableRow($id: ID!, $attributes: TableRowAttributes!) {
      updateTableRow(id: $id, attributes: $attributes) {
        tableRow { id }
      }
    }
  "

  graphql_variables do
    {
      id: table_row.id,
      attributes: graphql_attributes_for(:table_row)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the TableRow' do
    old_attributes = table_row.attributes
    execute_graphql
    expect(table_row.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update TableRow' do
    expect(response_data.dig('updateTableRow', 'tableRow', 'id'))
      .to be == table_row.id.to_s
  end
end
