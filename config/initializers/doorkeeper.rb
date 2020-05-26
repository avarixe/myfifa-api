Doorkeeper.configure do
  api_only
  base_controller 'ActionController::API'

  orm :active_record

  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_person || warden.authenticate!(scope: :user)
  end

  resource_owner_from_credentials do
    p = User.find_for_database_authentication(username: params[:username])
    # p ||= User.find_for_database_authentication(email: params[:email])
    p if p && p.valid_password?(params[:password])
  end

  # Access token expiration time (default 2 hours)
  access_token_expires_in 2.weeks

  # Define access token scopes for your provider
  # For more information go to https://github.com/applicake/doorkeeper/wiki/Using-Scopes
  # default_scopes  :public
  # optional_scopes :write

  skip_authorization do
    true
  end

  grant_flows %w(authorization_code implicit password client_credentials)
end
