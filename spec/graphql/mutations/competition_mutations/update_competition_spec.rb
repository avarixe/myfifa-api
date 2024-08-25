# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::UpdateCompetition, type: :graphql do
  let(:competition) { create(:competition) }
  let!(:user) { competition.team.user }

  graphql_operation "
    mutation updateCompetition($id: ID!, $attributes: CompetitionAttributes!) {
      updateCompetition(id: $id, attributes: $attributes) {
        competition { id }
      }
    }
  "

  graphql_variables do
    {
      id: competition.id,
      attributes: graphql_attributes_for(:competition)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Competition' do
    old_attributes = competition.attributes
    execute_graphql
    expect(competition.reload.attributes).not_to eq old_attributes
  end

  it 'returns the update Competition' do
    expect(response_data.dig('updateCompetition', 'competition', 'id'))
      .to eq competition.id.to_s
  end
end
