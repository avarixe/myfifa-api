# frozen_string_literal: true

class TokensController < Doorkeeper::TokensController
  include Authentication
  before_action :authenticate_user!, only: %i[revoke]

  # Overriding create action
  # POST /oauth/token
  def create
    response = strategy.authorize
    body = response.body

    if response.status == :ok
      # Use the resource_owner_id from token to identify the user
      body[:user] = User.find(response.token.resource_owner_id)
    end

    headers.merge! response.headers
    self.response_body = body.to_json
    self.status = response.status
  end

  private

    def token
      @token ||= doorkeeper_token
    end

    def authorized?
      current_user && token&.resource_owner_id == current_user.id
    end
end
