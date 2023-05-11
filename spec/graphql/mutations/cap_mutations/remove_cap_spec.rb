# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::RemoveCap, type: :graphql do
  let(:cap) { create(:cap) }
  let!(:user) { cap.team.user }

  graphql_operation "
    mutation removeCap($id: ID!) {
      removeCap(id: $id) {
        cap { id }
      }
    }
  "

  graphql_variables do
    { id: cap.id }
  end

  graphql_context do
    { current_user: user }
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
