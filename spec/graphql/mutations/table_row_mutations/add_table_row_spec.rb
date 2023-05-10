# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TableRowMutations::AddTableRow, type: :graphql do
  let(:stage) { create(:stage) }

  graphql_operation "
    mutation addTableRow($stageId: ID!, $attributes: TableRowAttributes!) {
      addTableRow(stageId: $stageId, attributes: $attributes) {
        tableRow { id }
      }
    }
  "

  graphql_variables do
    {
      stageId: stage.id,
      attributes: graphql_attributes_for(:table_row)
    }
  end

  graphql_context do
    { current_user: stage.team.user }
  end

  it 'creates a TableRow for the Stage' do
    record_id = response_data.dig('addTableRow', 'tableRow', 'id')
    expect(stage.reload.table_rows.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created TableRow' do
    expect(response_data.dig('addTableRow', 'tableRow', 'id'))
      .to be_present
  end
end
