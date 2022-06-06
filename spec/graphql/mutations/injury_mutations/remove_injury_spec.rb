# frozen_string_literal: true

require 'rails_helper'

describe Mutations::InjuryMutations::RemoveInjury, type: :graphql do
  subject { described_class }

  let(:injury) { create :injury }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:injury).returning('Injury') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeInjury($id: ID!) {
      removeInjury(id: $id) {
        injury { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: injury.id }
  end

  graphql_context do
    { current_user: injury.team.user }
  end

  it 'removes the Injury' do
    execute_graphql
    expect { injury.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Injury' do
    expect(response_data.dig('removeInjury', 'injury', 'id'))
      .to be == injury.id.to_s
  end
end
