# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::SubstituteCap, type: :graphql do
  let(:cap) { create(:cap, stop: 90) }
  let!(:user) { cap.team.user }
  let!(:other_pos) { Cap::POSITIONS[Cap::POSITIONS.index(cap.pos) - 1] }
  let(:player) { create(:player, team: cap.team) }

  graphql_operation "
    mutation substituteCap($id: ID!, $attributes: CapSubstitutionAttributes!) {
      substituteCap(id: $id, attributes: $attributes) {
        cap { id }
        replacement { id }
      }
    }
  "

  graphql_variables do
    {
      id: cap.id,
      attributes: {
        playerId: player.id,
        pos: other_pos,
        minute: 60,
        injured: true
      }
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'creates a replacement Cap' do
    execute_graphql
    expect(cap.reload.next).to be_present
  end

  it 'sets start of replacement Cap' do
    execute_graphql
    expect(cap.reload.next.start).to be == 60
  end

  it 'sets player of replacement Cap' do
    execute_graphql
    expect(cap.reload.next.player_id).to be == player.id
  end

  it 'sets position of replacement Cap' do
    execute_graphql
    expect(cap.reload.next.pos).to be == other_pos
  end

  it 'marks Cap as injured if toggled' do
    execute_graphql
    expect(cap.reload).to be_injured
  end

  it 'returns the updated Cap' do
    expect(response_data.dig('substituteCap', 'cap', 'id'))
      .to be == cap.id.to_s
  end

  it 'returns the replacement Cap' do
    expect(response_data.dig('substituteCap', 'replacement', 'id'))
      .to be == cap.reload.next_id.to_s
  end

  it 'does not update the Cap if not owned by User' do
    allow(cap).to receive(:team).and_return(create(:team))
    allow(Cap).to receive(:find).and_return(cap)
    execute_graphql
    expect(cap.next).not_to be_present
  end

  describe 'with invalid attributes' do
    graphql_variables do
      {
        id: cap.id,
        attributes: {
          playerId: player.id,
          pos: other_pos,
          minute: 100,
          injured: false
        }
      }
    end

    it 'does not affect original Cap' do
      execute_graphql
      expect(cap.reload.stop).to be == 90
    end

    it 'does not create a replacement Cap' do
      execute_graphql
      expect(cap.reload.next).to be_blank
    end

    it 'returns an error message' do
      expect(response['errors']).to be_present
    end
  end
end
