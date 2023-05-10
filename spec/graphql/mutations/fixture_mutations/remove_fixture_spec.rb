# frozen_string_literal: true

require 'rails_helper'

describe Mutations::FixtureMutations::RemoveFixture, type: :graphql do
  let(:fixture) { create(:fixture) }

  graphql_operation "
    mutation removeFixture($id: ID!) {
      removeFixture(id: $id) {
        fixture { id }
      }
    }
  "

  graphql_variables do
    { id: fixture.id }
  end

  graphql_context do
    { current_user: fixture.team.user }
  end

  it 'removes the Fixture' do
    execute_graphql
    expect { fixture.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Fixture' do
    expect(response_data.dig('removeFixture', 'fixture', 'id'))
      .to be == fixture.id.to_s
  end
end
