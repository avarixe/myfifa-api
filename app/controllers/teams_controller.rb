# frozen_string_literal: true

class TeamsController < APIController
  load_and_authorize_resource except: %i[create]

  def index
    render json: current_user.teams.to_json
  end

  def show
    render json: @team.to_json
  end

  def create
    @team = current_user.teams.new(new_team_params)
    save_record @team
  end

  def update
    @team.attributes = edit_team_params
    save_record @team
  end

  def destroy
    @team.destroy
    render json: @team
  end

  private

    def new_team_params
      params.require(:team).permit Team.permitted_create_attributes
    end

    def edit_team_params
      params.require(:team).permit Team.permitted_update_attributes
    end
end
