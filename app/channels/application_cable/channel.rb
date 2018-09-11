# frozen_string_literal: true

module ApplicationCable
  class Channel < ActionCable::Channel::Base
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
        @access_token ||= Doorkeeper::AccessToken.by_token(
          request.query_parameters[:access_token]
        )
      end
  end
end
