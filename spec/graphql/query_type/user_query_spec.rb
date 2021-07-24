# frozen_string_literal: true

require 'rails_helper'

describe QueryType, type: :graphql do
  subject { described_class }

  let(:user) { create :user }

  graphql_operation <<-GQL
    query fetchUser {
      user { id }
    }
  GQL

  graphql_context do
    { current_user: user }
  end

  it 'returns User' do
    expect(response_data['user']['id']).to be == user.id.to_s
  end
end
