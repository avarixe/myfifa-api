# frozen_string_literal: true

class TransfersController < APIController
  load_and_authorize_resource :player
  load_and_authorize_resource through: :player, shallow: true

  def index
    render json: @transfers
  end

  def show
    render json: @transfer
  end

  def create
    save_record @transfer
  end

  def update
    @transfer.attributes = transfer_params
    save_record @transfer
  end

  def destroy
    render json: @transfer.destroy
  end

  private

    def transfer_params
      params.require(:transfer).permit Transfer.permitted_attributes
    end
end
