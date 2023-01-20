# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PenaltyShootoutMutations::RemovePenaltyShootout, type: :graphql do
  subject { described_class }

  let(:penalty_shootout) { create(:penalty_shootout) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:penalty_shootout).returning('PenaltyShootout') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removePenaltyShootout($id: ID!) {
      removePenaltyShootout(id: $id) {
        penaltyShootout { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: penalty_shootout.id }
  end

  graphql_context do
    { current_user: penalty_shootout.team.user }
  end

  it 'removes the PenaltyShootout' do
    execute_graphql
    expect { penalty_shootout.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed PenaltyShootout' do
    expect(response_data.dig('removePenaltyShootout', 'penaltyShootout', 'id'))
      .to be == penalty_shootout.id.to_s
  end
end
