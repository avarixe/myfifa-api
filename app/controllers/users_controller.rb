class UsersController < APIController
  def sync
    render json: current_resource_owner.attributes, status: 200
  end
end
