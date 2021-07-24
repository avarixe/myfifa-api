# frozen_string_literal: true

require 'rails_helper'

describe ApplicationCable::Connection, type: :channel do
  let(:token) { create :access_token }

  it 'successfully connects with token' do
    connect '/cable', params: { access_token: token.token }
    expect(connection.current_user).to be == token.user
  end

  it 'rejects connection without token' do
    expect { connect '/cable' }.to have_rejected_connection
  end
end
