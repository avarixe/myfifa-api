class InjuriesController < APIController
  load_and_authorize_resource :player
  load_and_authorize_resource :injury, through: :player, shallow: true

  def index
    render json: @injuries
  end

  def show
    render json: @injury
  end

  def create
    save_record @injury, json: @player
  end

  def update
    @injury.attributes = injury_params
    save_record @injury, json: @injury.player
  end

  def destroy
    render json: @injury.destroy
  end

  private

    def injury_params
      params.require(:injury).permit Injury.permitted_attributes
    end
end
