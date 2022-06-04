# frozen_string_literal: true

require 'rails_helper'

describe Mutations::FixtureMutations::UpdateFixture, type: :graphql do
  subject { described_class }

  let(:fixture) { create :fixture }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('FixtureAttributes!') }
  it { is_expected.to have_a_field(:fixture).returning('Fixture') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateFixture($id: ID!, $attributes: FixtureAttributes!) {
      updateFixture(id: $id, attributes: $attributes) {
        fixture { id }
        errors { fullMessages }
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
    { current_user: fixture.team.user }
  end

  it 'updates the Fixture' do
    old_attributes = fixture.attributes
    execute_graphql
    expect(fixture.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Fixture' do
    expect(response_data.dig('updateFixture', 'fixture', 'id'))
      .to be == fixture.id.to_s
  end
end
