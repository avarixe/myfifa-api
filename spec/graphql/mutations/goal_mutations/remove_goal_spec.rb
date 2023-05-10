# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GoalMutations::RemoveGoal, type: :graphql do
  let(:goal) { create(:goal) }

  graphql_operation "
    mutation removeGoal($id: ID!) {
      removeGoal(id: $id) {
        goal { id }
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
