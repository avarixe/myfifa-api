# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AddTeam do
  subject { described_class }

  it { is_expected.to accept_argument(:attributes).of_type('TeamAttributes!') }
  it { is_expected.to have_a_field(:team).returning('Team') }
  it { is_expected.to have_a_field(:errors).returning('ValidationErrors') }

  describe 'execution', type: :graphql do
    let(:user) { create :user }

    graphql_operation <<-GQL
      mutation addTeam($attributes: TeamAttributes!) {
        addTeam(attributes: $attributes) {
          team { id }
          errors { fullMessages }
        }
      }
    GQL

    graphql_context do
      { current_user: user }
    end

    describe 'with valid attributes' do
      graphql_variables do
        { attributes: graphql_attributes_for(:team) }
      end

      it 'creates a new Team for the user' do
        execute_graphql
        expect(user.reload.teams.count).to be == 1
      end

      it 'returns the created Team' do
        expect(response_data.dig('addTeam', 'team', 'id'))
          .to be == user.teams.first.id.to_s
      end
    end

    describe 'with invalid attributes' do
      graphql_variables do
        { attributes: { name: Faker::Team.name } }
      end

      it 'returns errors if attributes are not valid' do
        expect(response_data.dig('addTeam', 'errors', 'fullMessages')).to be_present
      end
    end
  end
end
