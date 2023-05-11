# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  subject { described_class }

  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }
  let(:match) { create(:match, team:) }

  before do
    3.times do |i|
      create(:match, team:, played_on: match.played_on - (i + 2).days)
      create(:match, team:, played_on: match.played_on + (i + 2).days)
    end
    create(:match, played_on: match.played_on - 1.day)
    create(:match, played_on: match.played_on + 1.day)
  end

  graphql_operation <<-GQL
    query fetchMatch($id: ID!) {
      match(id: $id) {
        previousMatch { playedOn }
        nextMatch { playedOn }
      }
    }
  GQL

  graphql_variables do
    { id: match.id }
  end

  graphql_context do
    { current_user: user }
  end

  it 'returns the previous Match' do
    expect(response_data.dig('match', 'previousMatch', 'playedOn'))
      .to be == (match.played_on - 2.days).to_s
  end

  it 'returns the next Match' do
    expect(response_data.dig('match', 'nextMatch', 'playedOn'))
      .to be == (match.played_on + 2.days).to_s
  end
end
