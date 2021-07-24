# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = authenticate!
    end

    private

      def authenticate!
        user = access_token&.user
        user || reject_unauthorized_connection
      end

      def access_token
        @access_token ||= AccessToken.find_by(
          token: request.query_parameters[:access_token]
        )
      end
  end
end
