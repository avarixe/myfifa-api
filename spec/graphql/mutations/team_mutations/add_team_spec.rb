# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TeamMutations::AddTeam, type: :graphql do
  let(:user) { create(:user) }

  graphql_operation <<-GQL
    mutation addTeam($attributes: TeamAttributes!) {
      addTeam(attributes: $attributes) {
        team { id }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  describe 'with valid attributes' do
    graphql_variables do
      { attributes: graphql_attributes_for(:team) }
    end

    it 'creates a new Team for the user' do
      execute_graphql
      expect(user.reload.teams.count).to be == 1
    end

    it 'returns the created Team' do
      expect(response_data.dig('addTeam', 'team', 'id'))
        .to be == user.teams.first.id.to_s
    end
  end

  describe 'with invalid attributes' do
    graphql_variables do
      { attributes: { name: nil } }
    end

    it 'returns errors if attributes are not valid' do
      expect(response['errors']).to be_present
    end
  end
end
