# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SubstitutionMutations::AddSubstitution, type: :graphql do
  let(:match) { create(:match) }
  let!(:user) { match.team.user }

  graphql_operation "
    mutation addSubstitution($matchId: ID!, $attributes: SubstitutionAttributes!) {
      addSubstitution(matchId: $matchId, attributes: $attributes) {
        substitution { id }
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
    { current_user: user }
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
