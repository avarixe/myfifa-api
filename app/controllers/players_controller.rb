# frozen_string_literal: true

class PlayersController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

  def index
    render json: @players
  end

  def show
    render json: @player
  end

  def create
    @player = @team.players.new
    @player.attributes = player_params
    save_record @player
  end

  def update
    @player.attributes = player_params
    save_record @player
  end

  def destroy
    @player.destroy
    render json: @player
  end

  def release
    @player.current_contract&.terminate!
    render json: @player
  end

  def retire
    @player.current_contract&.retire!
    render json: @player
  end

  def history
    render json: @player.histories
  end

  private

    def player_params
      params
        .require(:player)
        .permit(
          *Player.permitted_attributes,
          sec_pos: [],
          contracts_attributes: Contract.permitted_attributes
        )
    end
end
