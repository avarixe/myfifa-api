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
    save_record @booking, json: @match.full_json
  end

  def update
    @booking.attributes = booking_params
    @match = Match.with_players.find(@booking.match_id)
    save_record @booking, json: @match.full_json
  end

  def destroy
    @booking.destroy
    @match = Match.with_players.find(@booking.match_id)
    render json: @match.full_json
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def booking_params
      params.require(:booking).permit Booking.permitted_attributes
    end
end
