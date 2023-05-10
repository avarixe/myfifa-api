# frozen_string_literal: true

require 'rails_helper'

describe Mutations::FixtureMutations::AddFixture, type: :graphql do
  let(:stage) { create(:stage) }

  graphql_operation "
    mutation addFixture($stageId: ID!, $attributes: FixtureAttributes!) {
      addFixture(stageId: $stageId, attributes: $attributes) {
        fixture { id }
      }
    }
  "

  graphql_variables do
    {
      stageId: stage.id,
      attributes: graphql_attributes_for(:fixture).merge(
        legsAttributes: [graphql_attributes_for(:fixture_leg)]
      )
    }
  end

  graphql_context do
    { current_user: stage.team.user }
  end

  it 'creates a Fixture for the Stage' do
    record_id = response_data.dig('addFixture', 'fixture', 'id')
    expect(stage.reload.fixtures.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Fixture' do
    expect(response_data.dig('addFixture', 'fixture', 'id'))
      .to be_present
  end
end
