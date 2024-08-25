# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TeamMutations::RemoveTeam, type: :graphql do
  let(:team) { create(:team) }
  let!(:user) { team.user }

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
    { current_user: user }
  end

  it 'removes the Team' do
    execute_graphql
    expect { team.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Team' do
    expect(response_data.dig('removeTeam', 'team', 'id'))
      .to eq team.id.to_s
  end

  it 'returns error messages when failed' do
    allow(team).to receive(:destroy).and_return(false)
    allow(Team).to receive(:find).and_return(team)
    expect(response['errors']).to be_present
  end

  it 'returns error message when Team not owned by User' do
    allow(team).to receive(:user).and_return(create(:user))
    allow(Team).to receive(:find).and_return(team)
    expect(response['errors']).to be_present
  end
end
