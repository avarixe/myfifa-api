# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::AddCompetition, type: :graphql do
  let(:team) { create(:team) }
  let!(:user) { team.user }

  graphql_operation "
    mutation addCompetition($teamId: ID!, $attributes: CompetitionAttributes!) {
      addCompetition(teamId: $teamId, attributes: $attributes) {
        competition { id }
      }
    }
  "

  graphql_variables do
    {
      teamId: team.id,
      attributes: graphql_attributes_for(:competition)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'creates a Competition for the Team' do
    record_id = response_data.dig('addCompetition', 'competition', 'id')
    expect(team.reload.competitions.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Competition' do
    expect(response_data.dig('addCompetition', 'competition', 'id'))
      .to be_present
  end
end
