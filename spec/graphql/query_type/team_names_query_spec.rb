# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  subject(:field) { described_class.fields['teamNames'] }

  let(:user) { create :user }

  it { is_expected.to accept_argument(:search).of_type('String') }

  describe 'when executed' do
    graphql_operation <<-GQL
      query fetchTeamNames($search: String) {
        teamNames(search: $search)
      }
    GQL

    graphql_context do
      { current_user: user }
    end

    before do
      team = create :team, user: user
      create_list :match, 3, team: team
      competition = create :competition, team: team
      stage = create :stage, competition: competition
      create_list :fixture, 3, stage: stage
      create_list :table_row, 3, stage: stage
    end

    it 'returns compiled Player data' do
      team_names = TeamNamesCompiler.new(user: user).results
      expect(team_names).to match(response_data['teamNames'])
    end
  end
end
