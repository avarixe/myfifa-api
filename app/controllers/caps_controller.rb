# frozen_string_literal: true

class CapsController < APIController
  include Searchable
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @caps = Cap
            .joins(:player)
            .includes(:player)
            .where(players: { team_id: params[:team_id] })
    render json: filter(@caps)
  end

  def index
    @caps = @caps.includes(:player)
    render json: @caps
  end

  def show
    render json: @cap
  end

  def create
    save_record @cap
  end

  def update
    @cap.attributes = cap_params
    save_record @cap
  end

  def destroy
    @cap.destroy
    render json: @cap
  end

  private

    def cap_params
      params.require(:cap).permit(Cap.permitted_attributes)
    end
end
