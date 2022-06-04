# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::RemoveCap, type: :graphql do
  subject { described_class }

  let(:cap) { create :cap }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to have_a_field(:cap).returning('Cap') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation removeCap($id: ID!) {
      removeCap(id: $id) {
        cap { id }
        errors { fullMessages }
      }
    }
  "

  graphql_variables do
    { id: cap.id }
  end

  graphql_context do
    { current_user: cap.team.user }
  end

  it 'removes the Cap' do
    execute_graphql
    expect { cap.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns the removed Cap' do
    expect(response_data.dig('removeCap', 'cap', 'id'))
      .to be == cap.id.to_s
  end
end
