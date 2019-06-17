# frozen_string_literal: true

class PlayerHistoriesController < APIController
  include Searchable

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @histories = PlayerHistory
                 .joins(:player)
                 .where(players: { team_id: params[:team_id] })
    render json: filter(@histories)
  end
end
