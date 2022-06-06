# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GoalMutations::RemoveGoal, type: :graphql do
  subject { described_class }

  let(:goal) { create :goal }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:goal).returning('Goal') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeGoal($id: ID!) {
      removeGoal(id: $id) {
        goal { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: goal.id }
  end

  graphql_context do
    { current_user: goal.team.user }
  end

  it 'removes the Goal' do
    execute_graphql
    expect { goal.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Goal' do
    expect(response_data.dig('removeGoal', 'goal', 'id'))
      .to be == goal.id.to_s
  end
end
