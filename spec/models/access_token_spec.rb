# frozen_string_literal: true

# == Schema Information
#
# Table name: access_tokens
#
#  id         :bigint           not null, primary key
#  expires_at :datetime
#  revoked_at :datetime
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_access_tokens_on_token    (token)
#  index_access_tokens_on_user_id  (user_id)
#
require 'rails_helper'

RSpec.describe AccessToken, type: :model do
  let(:token) { create :access_token }

  it 'has a valid factory' do
    expect(token).to be_valid
  end

  it 'automatically generates a secure token string' do
    expect(create(:access_token, token: nil).token).to be_present
  end

  it 'sets the token expiration to 2 weeks after creation' do
    expect(token.expires_at.to_i).to be == (token.created_at + 2.weeks).to_i
  end
end
