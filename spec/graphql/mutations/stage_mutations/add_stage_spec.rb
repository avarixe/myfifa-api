# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::AddStage, type: :graphql do
  let(:competition) { create(:competition) }
  let!(:user) { competition.team.user }

  graphql_operation "
    mutation addStage($competitionId: ID!, $attributes: StageAttributes!) {
      addStage(competitionId: $competitionId, attributes: $attributes) {
        stage { id }
      }
    }
  "

  graphql_variables do
    {
      competitionId: competition.id,
      attributes: graphql_attributes_for(:stage)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'creates a Stage for the Competition' do
    record_id = response_data.dig('addStage', 'stage', 'id')
    expect(competition.reload.stages.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Stage' do
    expect(response_data.dig('addStage', 'stage', 'id'))
      .to be_present
  end
end
