# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end
end
