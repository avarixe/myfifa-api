# frozen_string_literal: true

class PlayerHistoriesController < ApiController
  include Searchable

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @histories = PlayerHistory
                 .joins(:player)
                 .where(players: { team_id: @team.id })
    render json: filter(@histories)
  end
end
