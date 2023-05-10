# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::RemoveSquad, type: :graphql do
  let(:squad) { create(:squad) }

  graphql_operation "
    mutation removeSquad($id: ID!) {
      removeSquad(id: $id) {
        squad { id }
      }
    }
  "

  graphql_variables do
    { id: squad.id }
  end

  graphql_context do
    { current_user: squad.team.user }
  end

  it 'removes the Squad' do
    execute_graphql
    expect { squad.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Squad' do
    expect(response_data.dig('removeSquad', 'squad', 'id'))
      .to be == squad.id.to_s
  end
end
