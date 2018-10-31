# frozen_string_literal: true

class TableRowsController < APIController
  load_and_authorize_resource :stage
  load_and_authorize_resource through: :stage, shallow: true

  def index
    render json: @table_rows
  end

  def show
    render json: @table_row
  end

  def create
    save_record @table_row
  end

  def update
    @table_row.attributes = table_row_params
    save_record @table_row
  end

  def destroy
    @table_row.destroy
    render json: @table_row
  end

  private

    def table_row_params
      params.require(:table_row).permit TableRow.permitted_attributes
    end
end
