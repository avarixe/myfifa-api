class LoansController < APIController
  load_and_authorize_resource :player
  load_and_authorize_resource :loan, through: :player, shallow: true

  def index
    render json: @loans
  end

  def show
    render json: @loan
  end

  def create
    save_record @loan, json: @player
  end

  def update
    @loan.attributes = loan_params
    save_record @loan, json: @loan.player
  end

  def destroy
    render json: @loan.destroy
  end

  private

    def loan_params
      params.require(:loan).permit Loan.permitted_attributes
    end
end
