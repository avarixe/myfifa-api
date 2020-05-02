# frozen_string_literal: true

class StagesController < APIController
  include Searchable
  before_action :set_stage, only: %i[show update destroy]
  load_and_authorize_resource :competition
  load_and_authorize_resource through: :competition, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @stages = Stage
              .includes(:table_rows, fixtures: :legs)
              .joins(:competition)
              .where(competitions: { team_id: @team.id })
    render json: filter(@stages)
  end

  def index
    render json: @stages.includes(:table_rows, fixtures: :legs)
  end

  def show
    render json: @stage
  end

  def create
    save_record @stage
  end

  def update
    @stage.attributes = stage_params
    save_record @stage
  end

  def destroy
    @stage.destroy
    render json: @stage
  end

  private

    def set_stage
      @stage = Stage.includes(fixtures: :legs).find(params[:id])
    end

    def stage_params
      params.require(:stage).permit Stage.permitted_attributes
    end
end
