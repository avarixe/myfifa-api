# frozen_string_literal: true

require 'rails_helper'

describe Mutations::FixtureMutations::UpdateFixture, type: :graphql do
  let(:fixture) { create(:fixture) }
  let!(:user) { fixture.team.user }

  graphql_operation "
    mutation updateFixture($id: ID!, $attributes: FixtureAttributes!) {
      updateFixture(id: $id, attributes: $attributes) {
        fixture { id }
      }
    }
  "

  graphql_variables do
    {
      id: fixture.id,
      attributes: graphql_attributes_for(:fixture).merge(
        legsAttributes: [graphql_attributes_for(:fixture_leg)]
      )
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Fixture' do
    old_attributes = fixture.attributes
    execute_graphql
    expect(fixture.reload.attributes).not_to eq old_attributes
  end

  it 'returns the update Fixture' do
    expect(response_data.dig('updateFixture', 'fixture', 'id'))
      .to eq fixture.id.to_s
  end
end
