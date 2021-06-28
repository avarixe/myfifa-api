# frozen_string_literal: true

class SquadsController < ApiController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

  def index
    render json: @squads.includes(:squad_players)
  end

  def show
    render json: @squad
  end

  def create
    save_record @squad
  end

  def update
    @squad.attributes = squad_params
    save_record @squad
  end

  def destroy
    @squad.destroy
    render json: @squad
  end

  def store_lineup
    @match = Match.find(params[:match_id])
    @squad.store_lineup(@match)
    render json: @squad
  end

  private

    def squad_params
      params
        .require(:squad)
        .permit(
          *Squad.permitted_attributes,
          squad_players_attributes: SquadPlayer.permitted_attributes
        )
    end
end
