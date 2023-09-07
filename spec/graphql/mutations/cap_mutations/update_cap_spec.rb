# frozen_string_literal: true

require 'rails_helper'

describe Mutations::CapMutations::UpdateCap, type: :graphql do
  let(:cap) { create(:cap) }
  let!(:user) { cap.team.user }
  let!(:other_pos) { Cap::POSITIONS[Cap::POSITIONS.index(cap.pos) - 1] }

  graphql_operation "
    mutation updateCap($id: ID!, $attributes: CapAttributes!) {
      updateCap(id: $id, attributes: $attributes) {
        cap { id }
      }
    }
  "

  graphql_variables do
    {
      id: cap.id,
      attributes: {
        playerId: cap.player_id,
        pos: other_pos
      }
    }
  end

  graphql_context do
    { current_user: user }
  end

  it 'updates the Cap' do
    old_attributes = cap.attributes
    execute_graphql
    expect(cap.reload.attributes).not_to be == old_attributes
  end

  it 'returns the update Cap' do
    expect(response_data.dig('updateCap', 'cap', 'id'))
      .to be == cap.id.to_s
  end

  it 'does not update the Cap if not owned by User' do
    old_attributes = cap.attributes
    allow(cap).to receive(:team).and_return(create(:team))
    allow(Cap).to receive(:find).and_return(cap)
    execute_graphql
    expect(cap.reload.pos).to be == old_attributes['pos']
  end

  describe 'when conflicting with existing Position' do
    before do
      player = create(:player, team: cap.team)
      create(:cap, match: cap.match, player:, pos: other_pos, start: cap.start)
    end

    graphql_variables do
      {
        id: cap.id,
        attributes: {
          pos: other_pos
        }
      }
    end

    it 'sets new position to Cap' do
      execute_graphql
      expect(cap.reload.pos).to be == other_pos
    end

    it 'gives old position to conflicting Cap' do
      other_cap = Cap.last
      execute_graphql
      expect(other_cap.reload.pos).to be == cap.pos
    end

    it 'resets Cap position if failed' do
      cap.start = -1
      cap.save(validate: false)
      execute_graphql
      expect(cap.reload.pos).to be_present
    end
  end

  describe 'when conflicting with existing Player' do
    let(:player) { create(:player, team: cap.team) }

    before do
      create(:cap, match: cap.match, player:, pos: other_pos, start: cap.start)
    end

    graphql_variables do
      {
        id: cap.id,
        attributes: {
          playerId: player.id
        }
      }
    end

    it 'sets new position to Cap' do
      execute_graphql
      expect(cap.reload.pos).to be == other_pos
    end

    it 'gives old position to conflicting Cap' do
      other_cap = Cap.last
      execute_graphql
      expect(other_cap.reload.pos).to be == cap.pos
    end

    it 'resets Cap position if failed' do
      cap.start = -1
      cap.save(validate: false)
      execute_graphql
      expect(cap.reload.pos).to be_present
    end
  end
end
