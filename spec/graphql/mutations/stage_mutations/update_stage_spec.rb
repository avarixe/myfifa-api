# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::UpdateStage, type: :graphql do
  let(:stage) { create(:stage) }
  let!(:user) { stage.team.user }

  graphql_operation "
    mutation updateStage($id: ID!, $attributes: StageAttributes!) {
      updateStage(id: $id, attributes: $attributes) {
        stage { id }
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
    { current_user: user }
  end

  it 'updates the Stage' do
    old_attributes = stage.attributes
    execute_graphql
    expect(stage.reload.attributes).not_to eq old_attributes
  end

  it 'returns the update Stage' do
    expect(response_data.dig('updateStage', 'stage', 'id'))
      .to eq stage.id.to_s
  end
end
