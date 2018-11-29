# frozen_string_literal: true

class PenaltyShootoutController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true, singleton: true

  def show
    render json: @penalty_shootout
  end

  def create
    save_record @penalty_shootout
  end

  def update
    @penalty_shootout.attributes = penalty_shootout_params
    save_record @penalty_shootout
  end

  def destroy
    @penalty_shootout.destroy
    render json: @penalty_shootout
  end

  private

    def penalty_shootout_params
      params
        .require(:penalty_shootout)
        .permit(PenaltyShootout.permitted_attributes)
    end
end
