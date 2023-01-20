# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::UpdateSubstitution, type: :graphql do
  subject { described_class }

  let(:substitution) { create(:substitution) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('SubstitutionAttributes!') }
  it { is_expected.to have_a_field(:substitution).returning('Substitution') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateSubstitution($id: ID!, $attributes: SubstitutionAttributes!) {
      updateSubstitution(id: $id, attributes: $attributes) {
        substitution { id }
        errors { fullMessages }
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
    { current_user: substitution.team.user }
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
