# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }

  before do
    create_list(:match, 10, team:)
  end

  graphql_operation <<-GQL
    query fetchCompetitionStats($id: ID!) {
      team(id: $id) {
        competitionStats {
          competition
          season
          wins
          draws
          losses
          goalsFor
          goalsAgainst
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

  it 'returns compiled Competition data' do
    compiled_stats = CompetitionCompiler.new(team:).results
    response_data['team']['competitionStats'].each do |stats|
      stats = stats.transform_keys { |k| k.underscore.to_sym }
      expect(compiled_stats).to include(stats)
    end
  end
end
