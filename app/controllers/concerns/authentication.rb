# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  private

    def authenticate_user!(*)
      user = User.find_by(id: doorkeeper_token&.resource_owner_id)
      Thread.current[:current_user] = user

      return if current_user

      render json: { errors: ['User is not authenticated!'] },
             status: :unauthorized
    end

    def current_user
      Thread.current[:current_user]
    end
end
