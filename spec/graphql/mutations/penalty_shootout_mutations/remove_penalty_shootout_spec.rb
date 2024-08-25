# frozen_string_literal: true

require 'rails_helper'

describe Mutations::PenaltyShootoutMutations::RemovePenaltyShootout, type: :graphql do
  let(:penalty_shootout) { create(:penalty_shootout) }
  let!(:user) { penalty_shootout.team.user }

  graphql_operation "
    mutation removePenaltyShootout($id: ID!) {
      removePenaltyShootout(id: $id) {
        penaltyShootout { id }
      }
    }
  "

  graphql_variables do
    { id: penalty_shootout.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'removes the PenaltyShootout' do
    execute_graphql
    expect { penalty_shootout.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed PenaltyShootout' do
    expect(response_data.dig('removePenaltyShootout', 'penaltyShootout', 'id'))
      .to eq penalty_shootout.id.to_s
  end
end
