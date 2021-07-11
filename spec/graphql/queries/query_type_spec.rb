# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  subject { described_class }

  it { is_expected.to have_field(:teams).of_type('[Team!]!') }
  it { is_expected.to have_field(:team).of_type('Team!') }

  describe 'team query' do
    subject(:field) { described_class.fields['team'] }

    it 'requires an ID' do
      expect(field).to accept_argument(:id).of_type('ID!')
    end
  end

  describe 'teams query execution', type: :graphql do
    let(:user) { create :user }

    graphql_operation <<-GQL
      query fetchTeams {
        teams { id }
      }
    GQL

    graphql_context do
      { current_user: user }
    end

    it 'returns all Teams for user' do
      create_list :team, 3
      create_list :team, 3, user: user
      expect(response_data['teams'].pluck('id'))
        .to be == user.teams.pluck(:id).map(&:to_s)
    end
  end

  describe 'team query execution', type: :graphql do
    let(:user) { create :user }

    graphql_operation <<-GQL
      query fetchTeam($id: ID!) {
        team(id: $id) { id }
      }
    GQL

    graphql_context do
      { current_user: user }
    end

    describe 'for user owned Team' do
      let(:team) { create :team, user: user }

      graphql_variables do
        { id: team.id }
      end

      it 'returns specific Team' do
        expect(response_data.dig('team', 'id')).to be == team.id.to_s
      end
    end

    describe 'for Team not owned by user' do
      let(:team) { create :team }

      graphql_variables do
        { id: team.id }
      end

      it 'does not return specific Team' do
        expect { execute_graphql }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
