# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  let(:user) { create(:user) }

  describe 'when executed for Team' do
    graphql_operation <<-GQL
      query fetchOptions($category: OptionCategory!, $search: String) {
        options(category: $category, search: $search)
      }
    GQL

    graphql_variables do
      { category: 'Team' }
    end

    graphql_context do
      { current_user: user }
    end

    before do
      create_list(:team, 3)
      create_list(:team, 3, user:)
    end

    it 'returns the name of all entered Teams' do
      expect(response_data(:options)).to match_array(user.teams.pluck(:name))
    end
  end

  describe 'when executed for Team with search' do
    graphql_operation <<-GQL
      query fetchOptions($category: OptionCategory!, $search: String) {
        options(category: $category, search: $search)
      }
    GQL

    graphql_variables do
      {
        category: 'Team',
        search: 'TEAM 0'
      }
    end

    graphql_context do
      { current_user: user }
    end

    before do
      3.times do |i|
        create(:team, user:, name: "Team #{i}")
      end
    end

    it 'filters results to only matched Teams' do
      expect(response_data(:options)).to contain_exactly('Team 0')
    end
  end
end
