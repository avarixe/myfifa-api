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
FactoryBot.define do
  factory :access_token do
    user
  end
end
