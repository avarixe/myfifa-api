# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :json
    respond_to :html, only: []
    respond_to :xml, only: []

    before_action :not_allowed, only: %i[new edit cancel]

    def new
      super
    end

    def edit
      super
    end

    def cancel
      super
    end

    private

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
          email
          full_name
          username
        ]
      end
  end
end
