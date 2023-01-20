# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::UpdateCompetition, type: :graphql do
  subject { described_class }

  let(:competition) { create(:competition) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('CompetitionAttributes!') }
  it { is_expected.to have_a_field(:competition).returning('Competition') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateCompetition($id: ID!, $attributes: CompetitionAttributes!) {
      updateCompetition(id: $id, attributes: $attributes) {
        competition { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      id: competition.id,
      attributes: graphql_attributes_for(:competition)
    }
  end

  graphql_context do
    { current_user: competition.team.user }
  end

  it 'updates the Competition' do
    old_attributes = competition.attributes
    execute_graphql
    expect(competition.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Competition' do
    expect(response_data.dig('updateCompetition', 'competition', 'id'))
      .to be == competition.id.to_s
  end
end
