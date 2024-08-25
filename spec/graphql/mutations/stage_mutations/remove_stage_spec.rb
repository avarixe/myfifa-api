# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::RemoveStage, type: :graphql do
  let(:stage) { create(:stage) }
  let!(:user) { stage.team.user }

  graphql_operation "
    mutation removeStage($id: ID!) {
      removeStage(id: $id) {
        stage { id }
      }
    }
  "

  graphql_variables do
    { id: stage.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Stage' do
    execute_graphql
    expect { stage.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Stage' do
    expect(response_data.dig('removeStage', 'stage', 'id'))
      .to eq stage.id.to_s
  end
end
