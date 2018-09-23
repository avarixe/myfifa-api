# frozen_string_literal: true

class InjuriesController < APIController
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def index
    render json: @injuries
  end

  def show
    render json: @injury
  end

  def create
    save_record @injury
  end

  def update
    @injury.attributes = injury_params
    save_record @injury
  end

  def destroy
    @injury.destroy
    render json: @injury
  end

  private

    def injury_params
      params.require(:injury).permit Injury.permitted_attributes
    end
end
