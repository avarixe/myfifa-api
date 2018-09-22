# frozen_string_literal: true

class TeamChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user
    team = Team.find(params[:id])
    stream_from team
  end
end
