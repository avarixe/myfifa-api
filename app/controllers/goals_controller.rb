# frozen_string_literal: true

class GoalsController < ApiController
  include Searchable
  before_action :set_match, only: %i[create]
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @goals = Goal.joins(:match).where(matches: { team_id: @team.id })
    render json: filter(@goals)
  end

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
    @goal.destroy
    render json: @goal
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def goal_params
      params.require(:goal).permit Goal.permitted_attributes
    end
end
