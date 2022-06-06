# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::UpdateMatch, type: :graphql do
  subject { described_class }

  let(:match) { create :match }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('MatchAttributes!') }
  it { is_expected.to have_a_field(:match).returning('Match') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateMatch($id: ID!, $attributes: MatchAttributes!) {
      updateMatch(id: $id, attributes: $attributes) {
        match { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: match.id,
      attributes: graphql_attributes_for(:match)
    }
  end

  graphql_context do
    { current_user: match.team.user }
  end

  it 'updates the Match' do
    old_attributes = match.attributes
    execute_graphql
    expect(match.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Match' do
    expect(response_data.dig('updateMatch', 'match', 'id'))
      .to be == match.id.to_s
  end
end
