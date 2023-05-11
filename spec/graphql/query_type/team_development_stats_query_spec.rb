# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }

  graphql_operation <<-GQL
    query fetchTeamDevelopmentStats($id: ID!, $season: Int!) {
      team(id: $id) {
        teamDevelopmentStats(season: $season) {
          season
          startOvr
          startValue
          endOvr
          endValue
        }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  graphql_variables do
    {
      id: team.id,
      season: 0
    }
  end

  before do
    players = create_list(:player, 3, team:)
    team.increment_date 6.months
    players.each do |player|
      player.update ovr: Faker::Number.between(from: 50, to: 90),
                    value: Faker::Number.between(from: 50_000, to: 200_000_000)
    end
  end

  it 'returns Team average OVR and total Value data' do
    compiled_stats = TeamDevelopmentCompiler.new(team:, season: 0).results
    stats = response_data['team']['teamDevelopmentStats']
            .transform_keys { |k| k.underscore.to_sym }
            .transform_values(&:to_i)
    expect(compiled_stats).to include(stats)
  end
end
