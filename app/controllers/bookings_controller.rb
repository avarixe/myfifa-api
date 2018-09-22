# frozen_string_literal: true

class BookingsController < APIController
  before_action :set_match, only: %i[create]
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    render json: @bookings
  end

  def show
    render json: @booking
  end

  def create
    save_record @booking
  end

  def update
    @booking.attributes = booking_params
    save_record @booking
  end

  def destroy
    render json: @booking.destroy
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def booking_params
      params.require(:booking).permit Booking.permitted_attributes
    end
end
