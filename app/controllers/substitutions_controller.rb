# frozen_string_literal: true

class SubstitutionsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    render json: @substitutions
  end

  def show
    render json: @substitution
  end

  def create
    save_record @substitution
  end

  def update
    @substitution.attributes = substitution_params
    save_record @substitution
  end

  def destroy
    @substitution.destroy
    render json: @substitution
  end

  private

    def substitution_params
      params.require(:substitution).permit Substitution.permitted_attributes
    end
end
