# frozen_string_literal: true

require 'rails_helper'

describe Mutations::InjuryMutations::AddInjury, type: :graphql do
  let(:player) { create(:player) }

  graphql_operation "
    mutation addInjury($playerId: ID!, $attributes: InjuryAttributes!) {
      addInjury(playerId: $playerId, attributes: $attributes) {
        injury { id }
      }
    }
  "

  graphql_variables do
    {
      playerId: player.id,
      attributes: graphql_attributes_for(:injury).merge(
        startedOn: player.team.currently_on.to_s,
        endedOn: (player.team.currently_on + 3.months).to_s
      )
    }
  end

  graphql_context do
    { current_user: player.team.user }
  end

  it 'creates a Injury for the Player' do
    record_id = response_data.dig('addInjury', 'injury', 'id')
    expect(player.reload.injuries.pluck(:id))
      .to include record_id.to_i
  end

  it 'returns the created Injury' do
    expect(response_data.dig('addInjury', 'injury', 'id'))
      .to be_present
  end
end
