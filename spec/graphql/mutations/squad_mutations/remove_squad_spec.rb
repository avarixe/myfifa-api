# frozen_string_literal: true

require 'rails_helper'

describe Mutations::SquadMutations::RemoveSquad, type: :graphql do
  subject { described_class }

  let(:squad) { create(:squad) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:squad).returning('Squad') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeSquad($id: ID!) {
      removeSquad(id: $id) {
        squad { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: squad.id }
  end

  graphql_context do
    { current_user: squad.team.user }
  end

  it 'removes the Squad' do
    execute_graphql
    expect { squad.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Squad' do
    expect(response_data.dig('removeSquad', 'squad', 'id'))
      .to be == squad.id.to_s
  end
end
