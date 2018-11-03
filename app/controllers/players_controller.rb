# frozen_string_literal: true

class PlayersController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

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
    render json: @player.player_histories
  end

  def current_loan
    render json: @player.current_loan
  end

  def current_injury
    render json: @player.current_injury
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
