# frozen_string_literal: true

class StagesController < APIController
  load_and_authorize_resource :competition
  load_and_authorize_resource through: :competition, shallow: true

  def index
    @stages = @stages.includes(:table_rows, :fixtures)
    render json: @stages
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

    def stage_params
      params.require(:stage).permit Stage.permitted_attributes
    end
end
