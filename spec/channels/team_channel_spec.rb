# frozen_string_literal: true

require 'rails_helper'

describe TeamChannel do
  let(:user) { create(:user) }
  let(:team) { create(:team, user:) }

  before do
    # initialize connection with identifiers
    stub_connection current_user: user
  end

  it 'subscribes when team id is provided' do
    subscribe(id: team.id)
    expect(subscription).to have_stream_for(team)
  end

  it 'rejects Team not bound to user' do
    team = create(:team)
    subscribe(id: team.id)
    expect(subscription).to be_rejected
  end
end
