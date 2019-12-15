# frozen_string_literal: true

class MatchesController < APIController
  load_and_authorize_resource :team, except: %i[teams]
  load_and_authorize_resource through: :team,
                              shallow: true,
                              except: %i[teams]
  skip_authorize_resource only: :events

  def index
    @matches = @matches.preload(:penalty_shootout)
    render json: @matches
  end

  def show
    render json: @match
  end

  def create
    save_record @match
  end

  def update
    @match.attributes = match_params
    save_record @match
  end

  def destroy
    @match.destroy
    render json: @match
  end

  def events
    render json: @match.events
  end

  def apply_squad
    @squad = Squad.find(params[:squad_id])
    @match.apply(@squad)
    render json: @match
  end

  def teams
    @teams = Match.pluck(:home, :away).flatten.uniq.sort
    render json: @teams
  end

  private

    def match_params
      params.require(:match).permit(Match.permitted_attributes)
    end
end
