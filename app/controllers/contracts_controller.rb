# frozen_string_literal: true

class ContractsController < ApiController
  include Searchable
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @contracts = Contract.joins(:player).where(players: { team_id: @team.id })
    render json: filter(@contracts)
  end

  def index
    render json: @contracts
  end

  def show
    render json: @contract
  end

  def create
    save_record @contract
  end

  def update
    @contract.attributes = contract_params
    save_record @contract
  end

  def destroy
    @contract.destroy
    render json: @contract
  end

  private

    def contract_params
      params.require(:contract).permit Contract.permitted_attributes
    end
end
