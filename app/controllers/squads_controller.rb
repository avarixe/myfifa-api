# frozen_string_literal: true

class SquadsController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

  def index
    render json: @squads
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
    render json: @squad.destroy
  end

  private

    def squad_params
      params
        .require(:squad)
        .permit(
          *Squad.permitted_attributes,
          players_list: [],
          positions_list: []
        )
    end
end
