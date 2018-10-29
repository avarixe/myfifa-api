# frozen_string_literal: true

class FixturesController < ApplicationController
  before_action :set_fixture
  load_and_authorize_resource :stage
  load_and_authorize_resource through: :stage, shallow: true

  def index
    render json: @fixtures
  end

  def show
    render json: @fixture
  end

  def create
    save_record @fixture
  end

  def update
    @fixture.attributes = fixture_params
    save_record @fixture
  end

  def destroy
    @fixture.destroy
    render json: @fixture
  end

  private

    def set_fixture
      @fixture = Fixture.find(params[:id])
    end

    def fixture_params
      params.require(:fixture).permit Fixture.permitted_attributes
    end
end
