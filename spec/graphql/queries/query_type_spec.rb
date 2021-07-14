# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::QueryType do
  subject { described_class }

  it { is_expected.to have_field(:teams).of_type('[Team!]!') }
  it { is_expected.to have_field(:team).of_type('Team!') }
  it { is_expected.to have_field(:player).of_type('Player!') }
  it { is_expected.to have_field(:match).of_type('Match!') }
  it { is_expected.to have_field(:competition).of_type('Competition!') }

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

  %w[team player match competition].each do |type|
    describe "#{type} query", type: :graphql do
      subject(:field) { described_class.fields[type] }

      let(:user) { create :user }

      it 'requires an ID' do
        expect(field).to accept_argument(:id).of_type('ID!')
      end

      graphql_operation "
        query fetch#{type.titleize}($id: ID!) {
          #{type}(id: $id) { id }
        }
      "

      graphql_context do
        { current_user: user }
      end

      describe 'for user owned Team' do
        let(:record) do
          if type == 'team'
            create :team, user: user
          else
            create type.to_sym, team: create(:team, user: user)
          end
        end

        graphql_variables do
          { id: record.id }
        end

        it 'returns specific Team' do
          expect(response_data.dig(type, 'id')).to be == record.id.to_s
        end
      end

      describe "for #{type.titleize} not owned by user" do
        let(:record) { create type.to_sym }

        graphql_variables do
          { id: record.id }
        end

        it "does not return specific #{type.titleize}" do
          expect { execute_graphql }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
