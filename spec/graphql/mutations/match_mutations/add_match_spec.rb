# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::AddMatch, type: :graphql do
  let(:team) { create(:team) }

  graphql_operation "
    mutation addMatch($teamId: ID!, $attributes: MatchAttributes!) {
      addMatch(teamId: $teamId, attributes: $attributes) {
        match { id }
      }
    }
  "

  graphql_variables do
    {
      teamId: team.id,
      attributes: graphql_attributes_for(:match)
    }
  end

  graphql_context do
    { current_user: team.team.user }
  end

  it 'creates a Match for the Team' do
    record_id = response_data.dig('addMatch', 'match', 'id')
    expect(team.reload.matches.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Match' do
    expect(response_data.dig('addMatch', 'match', 'id'))
      .to be_present
  end
end
