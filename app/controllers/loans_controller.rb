class LoansController < APIController
  # load_and_authorize_resource :team
  load_and_authorize_resource :player
  load_and_authorize_resource :loan, through: :player, shallow: true, except: %i[create]

  def index
    render json: @loans
  end

  def show
    render json: @loan
  end

  def create
    @loan = @player.loans.new(new_loan_params)
    save_record @loan
  end

  def update
    @loan.attributes = edit_loan_params
    save_record @loan
  end

  def destroy
    render json: @loan.destroy
  end

  private

    def new_loan_params
      params.require(:loan).permit Loan.permitted_create_attributes
    end

    def edit_loan_params
      params.require(:loan).permit Loan.permitted_update_attributes
    end
end
