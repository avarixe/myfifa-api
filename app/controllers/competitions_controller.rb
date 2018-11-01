# frozen_string_literal: true

class CompetitionsController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true, except: [:destroy]

  def index
    render json: @competitions
  end

  def show
    render json: @competition
  end

  def create
    save_record @competition
  end

  def update
    @competition.attributes = competition_params
    save_record @competition
  end

  def destroy
    @competition = Competition
                   .includes(stages: %i[fixtures table_rows])
                   .find(params[:id])
    authorize! :destroy, @competition
    @competition.destroy
    render json: @competition
  end

  private

    def competition_params
      params.require(:competition).permit Competition.permitted_attributes
    end
end
