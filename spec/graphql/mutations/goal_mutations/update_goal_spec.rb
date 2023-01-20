# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GoalMutations::UpdateGoal, type: :graphql do
  subject { described_class }

  let(:goal) { create(:goal) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('GoalAttributes!') }
  it { is_expected.to have_a_field(:goal).returning('Goal') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateGoal($id: ID!, $attributes: GoalAttributes!) {
      updateGoal(id: $id, attributes: $attributes) {
        goal { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: goal.id,
      attributes: graphql_attributes_for(:goal)
    }
  end

  graphql_context do
    { current_user: goal.team.user }
  end

  it 'updates the Goal' do
    old_attributes = goal.attributes
    execute_graphql
    expect(goal.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Goal' do
    expect(response_data.dig('updateGoal', 'goal', 'id'))
      .to be == goal.id.to_s
  end
end
