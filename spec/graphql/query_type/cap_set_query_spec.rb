# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }
  let(:player) { create(:player, team:) }
  let(:pagination) { { page: 0, itemsPerPage: 10 } }
  let(:filters) { { result: %w[win draw loss] } }

  before do
    10.times do
      match = create(:match, team:, played_on: team.currently_on + 1.week)
      create(:cap, match:, player:)
    end
  end

  graphql_operation <<-GQL
    query fetchCapSet($playerId: ID!, $pagination: PaginationAttributes, $filters: MatchFilterAttributes) {
      player(id: $playerId) {
        capSet(pagination: $pagination, filters: $filters) {
          caps { id }
          total
        }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  graphql_variables do
    { playerId: player.id, pagination:, filters: }
  end

  it 'returns compiled Cap data' do
    cap_set = CapsCompiler.new(player:, pagination:, filters:)
    expect(response_data['player']['capSet']['caps'].map { |cap| cap['id'].to_i })
      .to match_array(cap_set.results.pluck(:id))
  end

  it 'returns total of Caps' do
    cap_set = CapsCompiler.new(player:, pagination:, filters:)
    expect(response_data['player']['capSet']['total']).to eq cap_set.total
  end
end
