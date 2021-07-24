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
class AccessToken < ApplicationRecord
  belongs_to :user

  has_secure_token length: 43

  scope :active, -> { where(expires_at: Time.current.., revoked_at: nil) }

  before_create :set_expires_at

  def set_expires_at
    self.expires_at = Time.current + 2.weeks
  end

  def revoked?
    revoked_at.present?
  end
end
