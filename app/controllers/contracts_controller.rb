class ContractsController < APIController
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def index
    render json: @contracts.as_json(include: :contract_histories)
  end

  def show
    render json: @contract
  end

  def create
    save_record @contract, json: @player
  end

  def update
    @contract.attributes = contract_params
    save_record @contract, json: @contract.player
  end

  def destroy
    render json: @contract.destroy
  end

  private

    def contract_params
      params.require(:contract).permit Contract.permitted_attributes
    end
end
