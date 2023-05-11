# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::UpdateMatch, type: :graphql do
  let(:match) { create(:match) }
  let!(:user) { match.team.user }

  graphql_operation "
    mutation updateMatch($id: ID!, $attributes: MatchAttributes!) {
      updateMatch(id: $id, attributes: $attributes) {
        match { id }
      }
    }
  "

  graphql_variables do
    {
      id: match.id,
      attributes: graphql_attributes_for(:match)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Match' do
    old_attributes = match.attributes
    execute_graphql
    expect(match.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Match' do
    expect(response_data.dig('updateMatch', 'match', 'id'))
      .to be == match.id.to_s
  end
end
