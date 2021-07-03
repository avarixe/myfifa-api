# frozen_string_literal: true

class UsersController < Devise::RegistrationsController
  include CanCan::ControllerAdditions

  clear_respond_to
  respond_to :json

  before_action :not_allowed, only: %i[new edit cancel]

  private

    def current_user
      @current_user ||= begin
        User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
      end
    end

    def not_allowed
      raise MethodNotAllowed
    end

    def sign_up_params
      params.require(:user).permit %i[
        email
        password
        password_confirmation
        full_name
        username
      ]
    end

    def account_update_params
      params.require(:user).permit %i[
        password
        password_confirmation
        current_password
      ]
    end
end
end
