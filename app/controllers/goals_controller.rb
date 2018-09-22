# frozen_string_literal: true

class GoalsController < APIController
  before_action :set_match, only: %i[create]
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    render json: @goals
  end

  def show
    render json: @goal
  end

  def create
    save_record @goal
  end

  def update
    @goal.attributes = goal_params
    save_record @goal
  end

  def destroy
    render json: @goal.destroy
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def goal_params
      params.require(:goal).permit Goal.permitted_attributes
    end
end
