class PlayersController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true
  skip_load_and_authorize_resource only: :update_multiple

  def index
    @players = @players.preload(:contracts)
    render json: @players
  end

  def show
    render json: @player
  end

  def create
    save_record @player
  end

  def update
    @player.attributes = player_params
    save_record @player
  end

  def destroy
    render json: @player.destroy
  end

  def update_multiple
    Player.update(params[:players].keys, params[:players].values)
    render json: @team.players.preload(:contracts, :injuries, :loans)
  end

  def active_loan
    render json: @player.active_loan
  end

  def active_injury
    render json: @player.active_injury
  end

  private

    def player_params
      params
        .require(:player)
        .permit(
          *Player.permitted_attributes,
          sec_pos: []
        )
    end
end
