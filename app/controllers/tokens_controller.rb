class TokensController < Doorkeeper::TokensController
  # Overriding create action
  # POST /oauth/token
  def create
    response = strategy.authorize
    body = response.body

    # if response.status == :ok
    #   User the resource_owner_id from token to identify the user
    #   user = User.find(response.token.resource_owner_id)
    #   body[:user] = user.as_json unless user.nil?
    # else
    unless response.status == :ok
      body[:errors] = ['Invalid Username/Password. Please try again.']
    end

    headers.merge! response.headers
    self.response_body = body.to_json
    self.status        = response.status
  rescue Doorkeeper::Errors::DoorkeeperError => e
    handle_token_exception e
  end
end
