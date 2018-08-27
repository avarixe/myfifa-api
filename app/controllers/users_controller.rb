# frozen_string_literal: true

class UsersController < APIController
  def sync
    render json: current_resource_owner.to_json, status: :ok
  end
end
