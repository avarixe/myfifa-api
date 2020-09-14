# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include CanCan::ControllerAdditions
    include Authentication

    clear_respond_to
    respond_to :json

    before_action :not_allowed, only: %i[new edit cancel]

    private

      def not_allowed
        raise MethodNotAllowed
      end

      def update_resource(resource, params)
        if params.include?(:password)
          super
        else
          resource.update_without_password(params)
        end
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
          email
          full_name
          username
          password
          password_confirmation
          current_password
        ]
      end
  end
end
