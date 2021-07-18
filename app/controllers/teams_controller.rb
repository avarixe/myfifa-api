# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :authenticate!
  before_action :set_team

  def add_badge
    if @team.update(team_badge_params)
      render json: @team.badge_path
    else
      render json: { errors: @team.errors.full_messages },
             status: :bad_request
    end
  end

  def remove_badge
    @team.badge.purge
    head :ok
  end

  private

    def team_badge_params
      params.require(:team).permit [:badge]
    end

    def set_team
      @team = current_user.teams.find(params[:id])
    end
end
