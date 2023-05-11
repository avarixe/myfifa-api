# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::UpdateSubstitution, type: :graphql do
  let(:substitution) { create(:substitution) }
  let!(:user) { substitution.team.user }

  graphql_operation "
    mutation updateSubstitution($id: ID!, $attributes: SubstitutionAttributes!) {
      updateSubstitution(id: $id, attributes: $attributes) {
        substitution { id }
      }
    }
  "

  graphql_variables do
    {
      id: substitution.id,
      attributes: graphql_attributes_for(:substitution).merge(
        playerId: substitution.player_id,
        replacementId: substitution.replacement_id
      )
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Substitution' do
    old_attributes = substitution.attributes
    execute_graphql
    expect(substitution.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Substitution' do
    expect(response_data.dig('updateSubstitution', 'substitution', 'id'))
      .to be == substitution.id.to_s
  end
end
