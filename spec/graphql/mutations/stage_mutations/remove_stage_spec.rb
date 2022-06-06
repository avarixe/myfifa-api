# frozen_string_literal: true

require 'rails_helper'

describe Mutations::StageMutations::RemoveStage, type: :graphql do
  subject { described_class }

  let(:stage) { create :stage }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:stage).returning('Stage') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeStage($id: ID!) {
      removeStage(id: $id) {
        stage { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: stage.id }
  end

  graphql_context do
    { current_user: stage.team.user }
  end

  it 'removes the Stage' do
    execute_graphql
    expect { stage.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Stage' do
    expect(response_data.dig('removeStage', 'stage', 'id'))
      .to be == stage.id.to_s
  end
end
