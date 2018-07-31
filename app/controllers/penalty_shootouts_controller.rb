class PenaltyShootoutsController < APIController
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
    save_record @penalty_shootout, json: @penalty_shootout.match.full_json
  end

  def destroy
    @match = @penalty_shootout.match
    @penalty_shootout.destroy
    @match.reload
    render json: @match.full_json
  end

  private

    def penalty_shootout_params
      params
        .require(:penalty_shootout)
        .permit(PenaltyShootout.permitted_attributes)
    end
end
