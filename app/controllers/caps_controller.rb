# frozen_string_literal: true

class CapsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    @caps = @caps.includes(:player)
    render json: @caps
  end

  def show
    render json: @cap
  end

  def create
    save_record @cap
  end

  def update
    @cap.attributes = cap_params
    save_record @cap
  end

  def destroy
    @cap.destroy
    render json: @cap
  end

  private

    def cap_params
      params.require(:cap).permit(Cap.permitted_attributes)
    end
end
