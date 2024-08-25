# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::RemoveCompetition, type: :graphql do
  let(:competition) { create(:competition) }
  let!(:user) { competition.team.user }

  graphql_operation "
    mutation removeCompetition($id: ID!) {
      removeCompetition(id: $id) {
        competition { id }
      }
    }
  "

  graphql_variables do
    { id: competition.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Competition' do
    execute_graphql
    expect { competition.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Competition' do
    expect(response_data.dig('removeCompetition', 'competition', 'id'))
      .to eq competition.id.to_s
  end
end
