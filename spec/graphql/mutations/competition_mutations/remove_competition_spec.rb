# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::RemoveCompetition, type: :graphql do
  subject { described_class }

  let(:competition) { create :competition }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:competition).returning('Competition') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeCompetition($id: ID!) {
      removeCompetition(id: $id) {
        competition { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: competition.id }
  end

  graphql_context do
    { current_user: competition.team.user }
  end

  it 'removes the Competition' do
    execute_graphql
    expect { competition.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Competition' do
    expect(response_data.dig('removeCompetition', 'competition', 'id'))
      .to be == competition.id.to_s
  end
end
