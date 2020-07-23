# frozen_string_literal: true

class MatchesController < APIController
  load_and_authorize_resource :team
  load_and_authorize_resource through: :team, shallow: true
  skip_authorize_resource only: :events

  def index
    @matches = @matches.preload(:penalty_shootout)
    render json: @matches
  end

  def show
    @match = Match.includes(caps: :player).find(params[:id])
    render json: @match.to_json(
      include: [
        :goals,
        :bookings,
        :penalty_shootout,
        caps: { methods: :name },
        substitutions: { methods: :home }
      ]
    )
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

  def apply_squad
    @squad = Squad.find(params[:squad_id])
    @match.apply(@squad)
    render json: @match.to_json(include: :caps)
  end

  def team_options
    @team_options = @team.matches.pluck(:home, :away).flatten.uniq.sort
    render json: @team_options
  end

  private

    def match_params
      params.require(:match).permit(Match.permitted_attributes)
    end
end
