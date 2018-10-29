# frozen_string_literal: true

class CompetitionsController < APIController
  before_action :set_competition
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

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
    @competition.destroy
    render json: @competition
  end

  private

    def set_competition
      @competition = Competition.find(params[:id])
    end

    def competition_params
      params.require(:competition).permit Competition.permitted_attributes
    end
end
