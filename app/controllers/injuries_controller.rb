# frozen_string_literal: true

class InjuriesController < ApiController
  include Searchable
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @injuries = Injury.joins(:player).where(players: { team_id: @team.id })
    render json: filter(@injuries)
  end

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
