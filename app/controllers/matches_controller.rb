class MatchesController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource :match, through: :team, shallow: true

  def index
    render json: @matches
  end

  def show
    render json: @match
  end

  def create
    @match = @team.matches.new(match_params)
    save_record @match
  end

  def update
    @match.attributes = match_params
    save_record @match
  end

  def destroy
    render json: @match.destroy
  end

  private

    def match_params
      params.require(:match).permit(Match.permitted_attributes)
    end
end
