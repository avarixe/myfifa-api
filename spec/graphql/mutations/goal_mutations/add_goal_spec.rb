# frozen_string_literal: true

require 'rails_helper'

describe Mutations::GoalMutations::AddGoal, type: :graphql do
  let(:match) { create(:match) }
  let!(:user) { match.team.user }

  graphql_operation "
    mutation addGoal($matchId: ID!, $attributes: GoalAttributes!) {
      addGoal(matchId: $matchId, attributes: $attributes) {
        goal { id }
      }
    }
  "

  graphql_variables do
    {
      matchId: match.id,
      attributes: graphql_attributes_for(:goal)
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'creates a Goal for the Match' do
    record_id = response_data.dig('addGoal', 'goal', 'id')
    expect(match.reload.goals.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Goal' do
    expect(response_data.dig('addGoal', 'goal', 'id'))
      .to be_present
  end
end
