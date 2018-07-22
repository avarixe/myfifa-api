class MatchesController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true

  def index
    @matches = @matches.preload(:players, :goals, :substitutions, :bookings, :penalty_shootout)
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
    render json: @match.destroy
  end

  def apply_squad
    @squad = Squad.find(params[:squad_id])
    @match.apply(@squad)
    render json: @match
  end

  private

    def match_params
      params.require(:match).permit(Match.permitted_attributes)
    end
end
