# frozen_string_literal: true

class UsersController < ApiController
  def sync
    render json: current_resource_owner.to_json, status: :ok
  end
end
