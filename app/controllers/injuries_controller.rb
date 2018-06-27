class InjuriesController < APIController
  # load_and_authorize_resource :team
  load_and_authorize_resource :player
  load_and_authorize_resource :injury, through: :player, shallow: true, except: %i[create]

  def index
    render json: @injuries
  end

  def show
    render json: @injury
  end

  def create
    @injury = @player.injuries.new(injury_params)
    save_record @injury
  end

  def update
    @injury.attributes = injury_params
    save_record @injury
  end

  def destroy
    render json: @injury.destroy
  end

  private

    def injury_params
      params.require(:injury).permit Injury.permitted_attributes
    end
end
