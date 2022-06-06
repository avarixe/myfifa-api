# frozen_string_literal: true

require 'rails_helper'

describe Mutations::MatchMutations::RemoveMatch, type: :graphql do
  subject { described_class }

  let(:match) { create :match }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:match).returning('Match') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeMatch($id: ID!) {
      removeMatch(id: $id) {
        match { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: match.id }
  end

  graphql_context do
    { current_user: match.team.user }
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
