# frozen_string_literal: true

require 'rails_helper'

describe Mutations::InjuryMutations::UpdateInjury, type: :graphql do
  subject { described_class }

  let(:injury) { create(:injury) }

  it { is_expected.to accept_argument(:id).of_type('ID!') }
  it { is_expected.to accept_argument(:attributes).of_type('InjuryAttributes!') }
  it { is_expected.to have_a_field(:injury).returning('Injury') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  graphql_operation "
    mutation updateInjury($id: ID!, $attributes: InjuryAttributes!) {
      updateInjury(id: $id, attributes: $attributes) {
        injury { id }
        errors { fullMessages }
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
    { current_user: injury.team.user }
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
