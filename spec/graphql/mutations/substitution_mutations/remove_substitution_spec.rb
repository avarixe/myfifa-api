# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::RemoveSubstitution, type: :graphql do
  subject { described_class }

  let(:substitution) { create :substitution }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:substitution).returning('Substitution') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeSubstitution($id: ID!) {
      removeSubstitution(id: $id) {
        substitution { id }
        errors { fullMessages }
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
