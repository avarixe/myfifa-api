# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }
  let(:pagination) { { page: 0, itemsPerPage: 10 } }
  let(:filters) { { result: %w[win draw loss] } }

  before do
    create_list(:match, 10, team:)
  end

  graphql_operation <<-GQL
    query fetchMatchSet($teamId: ID!, $pagination: PaginationAttributes, $filters: MatchFilterAttributes) {
      team(id: $teamId) {
        matchSet(pagination: $pagination, filters: $filters) {
          matches { id }
          total
        }
      }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  graphql_variables do
    { teamId: team.id, pagination:, filters: }
  end

  it 'returns compiled Match data' do
    match_set = MatchesCompiler.new(team:, pagination:, filters:)
    expect(response_data['team']['matchSet']['matches'].map { |match| match['id'].to_i })
      .to match_array(match_set.results.pluck(:id))
  end

  it 'returns total of Matches' do
    match_set = MatchesCompiler.new(team:, pagination:, filters:)
    expect(response_data['team']['matchSet']['total']).to eq match_set.total
  end
end
