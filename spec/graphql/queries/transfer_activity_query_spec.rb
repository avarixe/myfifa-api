# frozen_string_literal: true

require 'rails_helper'

describe Types::QueryType, type: :graphql do
  let(:user) { create :user }
  let(:team) { create :team, user: user }

  graphql_operation <<-GQL
    query fetchTransferActivity($id: ID!) {
      team(id: $id) {
        transferActivity {
          arrivals { id }
          departures { id }
          transfers { id }
          loans { id }
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
    players = create_list :player, 3, team: team
    create :transfer, player: players[0], origin: team.name
    create :loan, player: players[1]
  end

  it 'returns compiled Transfer Activity data' do
    response_data['team']['transferActivity'].each do |key, data|
      %i[arrivals departures transfers loans].each do |key|
        expect(data).to be_present
      end
    end
  end
end
