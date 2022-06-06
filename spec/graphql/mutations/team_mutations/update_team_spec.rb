# frozen_string_literal: true

require 'rails_helper'

describe Mutations::TeamMutations::UpdateTeam, type: :graphql do
  subject { described_class }

  let(:team) { create :team }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('TeamAttributes!') }
  it { is_expected.to have_a_field(:team).returning('Team') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateTeam($id: ID!, $attributes: TeamAttributes!) {
      updateTeam(id: $id, attributes: $attributes) {
        team { id }
        errors { fullMessages }
      }
    }
  "

  graphql_context do
    { current_user: team.user }
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
      expect(team.reload.attributes).not_to be == old_attributes
    end

    it 'returns the update Team' do
      expect(response_data.dig('updateTeam', 'team', 'id'))
        .to be == team.id.to_s
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
      execute_graphql
      expect(response_data.dig('updateTeam', 'errors')).to be_present
    end
  end
end