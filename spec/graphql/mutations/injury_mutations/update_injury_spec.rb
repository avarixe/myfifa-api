# frozen_string_literal: true

require 'rails_helper'

describe Mutations::InjuryMutations::UpdateInjury, type: :graphql do
  let(:injury) { create(:injury) }
  let!(:user) { injury.team.user }

  graphql_operation "
    mutation updateInjury($id: ID!, $attributes: InjuryAttributes!) {
      updateInjury(id: $id, attributes: $attributes) {
        injury { id }
      }
    }
  "

  graphql_variables do
    {
      id: injury.id,
      attributes: graphql_attributes_for(:injury).merge(
        startedOn: injury.team.currently_on.to_s,
        endedOn: (injury.team.currently_on + 3.months).to_s
      )
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Injury' do
    old_attributes = injury.attributes
    execute_graphql
    expect(injury.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Injury' do
    expect(response_data.dig('updateInjury', 'injury', 'id'))
      .to be == injury.id.to_s
  end
end
