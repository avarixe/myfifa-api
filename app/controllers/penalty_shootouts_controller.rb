# frozen_string_literal: true

class PenaltyShootoutsController < APIController
  before_action :set_match, only: %i[create]
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true, singleton: true

  def show
    render json: @penalty_shootout
  end

  def create
    save_record @penalty_shootout, json: @match.full_json
  end

  def update
    @penalty_shootout.attributes = penalty_shootout_params
    @match = Match.with_players.find(@penalty_shootout.match_id)
    save_record @penalty_shootout, json: @match.full_json
  end

  def destroy
    @match = Match.with_players.find(@penalty_shootout.match_id)
    @penalty_shootout.destroy
    render json: @match.full_json
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def penalty_shootout_params
      params
        .require(:penalty_shootout)
        .permit(PenaltyShootout.permitted_attributes)
    end
end
