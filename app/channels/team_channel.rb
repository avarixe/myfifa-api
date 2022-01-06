# frozen_string_literal: true

class TeamChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user
    team = current_user.teams.find(params[:id])
    stream_for team
  end
end
