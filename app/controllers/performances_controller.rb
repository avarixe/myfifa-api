class PerformancesController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    @performances = @performances.includes(:player)
    render json: @performances
  end

  def show
    render json: @performance
  end

  def create
    save_record @performance
  end

  def update
    @performance.attributes = performance_params
    save_record @performance
  end

  private

    def performance_params
      params.require(:performance).permit(Performance.permitted_attributes)
    end
end
