class PlayersController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource :player, through: :team, shallow: true, except: %i[create]

  def index
    render json: @players
  end

  def show
    # byebug
    render json: @player
  end

  def create
    @player = @team.players.new(player_params)
    save_record @player
  end

  def update
    @player.attributes = player_params
    save_record @player
  end

  def destroy
    render json: @player.destroy
  end

  private

    def player_params
      params.require(:player).permit(*Player.permitted_attributes, { sec_pos: [] })
    end
end
