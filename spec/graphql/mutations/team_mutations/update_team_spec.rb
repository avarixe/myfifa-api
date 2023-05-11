# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TeamMutations::UpdateTeam, type: :graphql do
  let(:team) { create(:team) }
  let!(:user) { team.user }

  graphql_operation "
    mutation updateTeam($id: ID!, $attributes: TeamAttributes!) {
      updateTeam(id: $id, attributes: $attributes) {
        team { id }
      }
    }
  "

  graphql_context do
    { current_user: user }
  end

  describe 'with valid attributes' do
    graphql_variables do
      {
        id: team.id,
        attributes: graphql_attributes_for(:team)
      }
    end

    it 'updates the Team' do
      old_attributes = team.attributes
      execute_graphql
      expect(team.reload.name).not_to be == old_attributes['name']
    end

    it 'returns the update Team' do
      expect(response_data.dig('updateTeam', 'team', 'id'))
        .to be == team.id.to_s
    end

    it 'does not update the Team if not owned by User' do
      old_attributes = team.attributes
      allow(team).to receive(:user).and_return(create(:user))
      allow(Team).to receive(:find).and_return(team)
      execute_graphql
      expect(team.reload.name).to be == old_attributes['name']
    end
  end

  describe 'with invalid attributes' do
    graphql_variables do
      {
        id: team.id,
        attributes: { name: nil }
      }
    end

    it 'does not update the Team' do
      execute_graphql
      expect(team.reload.name).not_to be_nil
    end

    it 'returns an error message' do
      expect(response['errors']).to be_present
    end
  end
end
