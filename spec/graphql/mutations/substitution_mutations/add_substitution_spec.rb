# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::AddSubstitution, type: :graphql do
  subject { described_class }

  let(:match) { create(:match) }

  it { is_expected.to accept_argument(:match_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('SubstitutionAttributes!') }
  it { is_expected.to have_a_field(:substitution).returning('Substitution') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addSubstitution($matchId: ID!, $attributes: SubstitutionAttributes!) {
      addSubstitution(matchId: $matchId, attributes: $attributes) {
        substitution { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      matchId: match.id,
      attributes: graphql_attributes_for(:substitution).merge(
        playerId: create(:player, team: match.team).id,
        replacementId: create(:player, team: match.team).id
      )
    }
  end

  graphql_context do
    { current_user: match.team.user }
  end

  it 'creates a Substitution for the Match' do
    record_id = response_data.dig('addSubstitution', 'substitution', 'id')
    expect(match.reload.substitutions.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Substitution' do
    expect(response_data.dig('addSubstitution', 'substitution', 'id'))
      .to be_present
  end
end
