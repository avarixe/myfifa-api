# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TeamMutations::RemoveTeam, type: :graphql do
  let(:team) { create(:team) }

  graphql_operation "
    mutation removeTeam($id: ID!) {
      removeTeam(id: $id) {
        team { id }
      }
    }
  "

  graphql_variables do
    { id: team.id }
  end

  graphql_context do
    { current_user: team.user }
  end

  it 'removes the Team' do
    execute_graphql
    expect { team.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Team' do
    expect(response_data.dig('removeTeam', 'team', 'id'))
      .to be == team.id.to_s
  end

  it 'returns error messages when failed' do
    team_stub = build_stubbed(:team)
    allow(team).to receive(:destroy).and_return(false)
    allow(Team).to receive(:find).and_return(team)
    execute_graphql(
      variables: { id: team_stub.id },
      context: { current_user: team_stub.user }
    )
    expect(response['errors']).to be_present
  end
end
