# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::RemoveSubstitution, type: :graphql do
  let(:substitution) { create(:substitution) }

  graphql_operation "
    mutation removeSubstitution($id: ID!) {
      removeSubstitution(id: $id) {
        substitution { id }
      }
    }
  "

  graphql_variables do
    { id: substitution.id }
  end

  graphql_context do
    { current_user: substitution.team.user }
  end

  it 'removes the Substitution' do
    execute_graphql
    expect { substitution.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Substitution' do
    expect(response_data.dig('removeSubstitution', 'substitution', 'id'))
      .to be == substitution.id.to_s
  end
end
