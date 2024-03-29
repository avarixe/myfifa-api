# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }

  graphql_operation <<-GQL
    query fetchPlayerDevelopmentStats($id: ID!) {
      team(id: $id) {
        playerDevelopmentStats {
          season
          playerId
          ovr
          value
        }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  graphql_variables do
    { id: team.id }
  end

  before do
    players = create_list(:player, 3, team:)
    matches = create_list(:match, 3, team:)
    create_list(:goal, 3, player: players.sample, match: matches.sample)
    matches.each do |match|
      players.each_with_index do |player, i|
        create(:cap, player:, match:, pos: Cap::POSITIONS[i])
      end
    end
  end

  it 'returns compiled Player data' do
    compiled_stats = PlayerDevelopmentCompiler.new(team:).results
    response_data['team']['playerDevelopmentStats'].each do |stats|
      stats = stats.transform_keys { |k| k.underscore.to_sym }
      stats[:player_id] = stats[:player_id].to_i
      expect(compiled_stats).to include(stats)
    end
  end
end
