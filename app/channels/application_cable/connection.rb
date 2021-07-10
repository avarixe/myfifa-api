# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate!
    end

    private

      def authenticate!
        user = User.find_by(id: access_token.try(:resource_owner_id))
        user || reject_unauthorized_connection
      end

      def access_token
        @access_token ||= Doorkeeper::OAuth::Token.authenticate(
          request,
          :from_bearer_authorization
        )
      end
  end
end
