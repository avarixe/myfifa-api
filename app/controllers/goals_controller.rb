class GoalsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    render json: @goals
  end

  def show
    render json: @goal
  end

  def create
    save_record @goal, json: @match
  end

  def update
    @goal.attributes = goal_params
    save_record @goal, json: @goal.match
  end

  def destroy
    @goal.destroy
    render json: @goal.match
  end

  private

    def goal_params
      params.require(:goal).permit Goal.permitted_attributes
    end
end