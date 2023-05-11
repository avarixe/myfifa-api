# frozen_string_literal: true

require 'rails_helper'

describe Mutations::InjuryMutations::RemoveInjury, type: :graphql do
  let(:injury) { create(:injury) }
  let!(:user) { injury.team.user }

  graphql_operation "
    mutation removeInjury($id: ID!) {
      removeInjury(id: $id) {
        injury { id }
      }
    }
  "

  graphql_variables do
    { id: injury.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the Injury' do
    execute_graphql
    expect { injury.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Injury' do
    expect(response_data.dig('removeInjury', 'injury', 'id'))
      .to be == injury.id.to_s
  end
end
