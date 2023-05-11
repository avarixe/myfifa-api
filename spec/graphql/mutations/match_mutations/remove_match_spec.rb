# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::RemoveMatch, type: :graphql do
  let(:match) { create(:match) }
  let!(:user) { match.team.user }

  graphql_operation "
    mutation removeMatch($id: ID!) {
      removeMatch(id: $id) {
        match { id }
      }
    }
  "

  graphql_variables do
    { id: match.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Match' do
    execute_graphql
    expect { match.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Match' do
    expect(response_data.dig('removeMatch', 'match', 'id'))
      .to be == match.id.to_s
  end
end
