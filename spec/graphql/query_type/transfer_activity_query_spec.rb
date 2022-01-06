# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
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
    { current_user: user, pundit: PunditProvider.new(user: user) }
  end

  graphql_variables do
    { id: team.id }
  end

  before do
    players = create_list :player, 3, team: team
    create :transfer, player: players[0], origin: team.name
    create :loan, player: players[1]
    players[2].current_contract.terminate!
  end

  it 'returns compiled Transfer Activity data' do
    %w[arrivals departures transfers loans].each do |key|
      expect(response_data['team']['transferActivity'][key]).to be_present
    end
  end
end
