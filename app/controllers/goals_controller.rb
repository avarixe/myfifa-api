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
    save_record @goal, json: proc { @match.full_json }
  end

  def update
    @goal.attributes = goal_params
    @match = Match.with_players.find(@goal.match_id)
    save_record @goal, json: @match.full_json
  end

  def destroy
    @goal.destroy
    @match = Match.with_players.find(@goal.match_id)
    render json: @match.full_json
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def goal_params
      params.require(:goal).permit Goal.permitted_attributes
    end
end
