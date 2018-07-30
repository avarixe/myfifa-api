class MatchesController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true
  skip_authorize_resource only: :events

  def index
    @matches = @matches.preload(
      :goals,
      :penalty_shootout
    )
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
    save_record @match.full_json
  end

  def destroy
    render json: @match.destroy
  end

  def events
    render json: @match.events
  end

  def apply_squad
    @squad = Squad.find(params[:squad_id])
    @match.apply(@squad)
    render json: @match.match_logs
  end

  private

    def match_params
      params.require(:match).permit(Match.permitted_attributes)
    end
end
