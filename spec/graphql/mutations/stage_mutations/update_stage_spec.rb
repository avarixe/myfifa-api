# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::UpdateStage, type: :graphql do
  subject { described_class }

  let(:stage) { create(:stage) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('StageAttributes!') }
  it { is_expected.to have_a_field(:stage).returning('Stage') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateStage($id: ID!, $attributes: StageAttributes!) {
      updateStage(id: $id, attributes: $attributes) {
        stage { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: stage.id,
      attributes: graphql_attributes_for(:stage)
    }
  end

  graphql_context do
    { current_user: stage.team.user }
  end

  it 'updates the Stage' do
    old_attributes = stage.attributes
    execute_graphql
    expect(stage.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Stage' do
    expect(response_data.dig('updateStage', 'stage', 'id'))
      .to be == stage.id.to_s
  end
end
