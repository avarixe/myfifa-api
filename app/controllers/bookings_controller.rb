class BookingsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def index
    render json: @bookings
  end

  def show
    render json: @booking
  end

  def create
    save_record @booking, json: @match.full_json
  end

  def update
    @booking.attributes = booking_params
    save_record @booking, json: @booking.match.full_json
  end

  def destroy
    @booking.destroy
    render json: @booking.match.full_json
  end

  private

    def booking_params
      params.require(:booking).permit Booking.permitted_attributes
    end
end