# frozen_string_literal: true

class TableRowsController < ApplicationController
  before_action :set_table_row
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

    def set_table_row
      @table_row = TableRow.find(params[:id])
    end

    def table_row_params
      params.require(:table_row).permit TableRow.permitted_attributes
    end
end
