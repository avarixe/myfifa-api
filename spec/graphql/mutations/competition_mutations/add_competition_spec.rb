# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CompetitionMutations::AddCompetition, type: :graphql do
  subject { described_class }

  let(:team) { create(:team) }

  it { is_expected.to accept_argument(:team_id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('CompetitionAttributes!') }
  it { is_expected.to have_a_field(:competition).returning('Competition') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation addCompetition($teamId: ID!, $attributes: CompetitionAttributes!) {
      addCompetition(teamId: $teamId, attributes: $attributes) {
        competition { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    {
      teamId: team.id,
      attributes: graphql_attributes_for(:competition)
    }
  end

  graphql_context do
    { current_user: team.team.user }
  end

  it 'creates a Competition for the Team' do
    record_id = response_data.dig('addCompetition', 'competition', 'id')
    expect(team.reload.competitions.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Competition' do
    expect(response_data.dig('addCompetition', 'competition', 'id'))
      .to be_present
  end
end
