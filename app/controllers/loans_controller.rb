# frozen_string_literal: true

class LoansController < APIController
  include Searchable
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @loans = Loan.where(player_id: @team.players.pluck(:id))
    render json: filter(@loans)
  end

  def index
    render json: @loans
  end

  def show
    render json: @loan
  end

  def create
    save_record @loan
  end

  def update
    @loan.attributes = loan_params
    save_record @loan
  end

  def destroy
    @loan.destroy
    render json: @loan
  end

  private

    def loan_params
      params.require(:loan).permit Loan.permitted_attributes
    end
end
