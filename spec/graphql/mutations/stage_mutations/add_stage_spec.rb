# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::AddStage, type: :graphql do
  subject { described_class }

  let(:competition) { create :competition }

  it { is_expected.to accept_argument(:competition_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('StageAttributes!') }
  it { is_expected.to have_a_field(:stage).returning('Stage') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addStage($competitionId: ID!, $attributes: StageAttributes!) {
      addStage(competitionId: $competitionId, attributes: $attributes) {
        stage { id }
        errors { fullMessages }
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
    { current_user: competition.team.user }
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
