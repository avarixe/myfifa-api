class InjuriesController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource :player
  load_and_authorize_resource :injury, through: :player, except: %i[create]


  def index
    render json: @injuries
  end

  def show
    render json: @injury
  end

  def create
    @injury = @player.injuries.new(new_injury_params)
    save_record @injury
  end

  def update
    @injury.attributes = edit_injury_params
    save_record @injury
  end

  def destroy
    render json: @injury.destroy
  end

  private

    def new_injury_params
      params.require(:injury).permit Injury.permitted_create_attributes
    end

    def edit_injury_params
      params.require(:injury).permit Injury.permitted_update_attributes
    end
end
