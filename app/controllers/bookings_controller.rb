# frozen_string_literal: true

class BookingsController < APIController
  include Searchable
  before_action :set_match, only: %i[create]
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def search
    @team = Team.find(params[:team_id])
    authorize! :show, @team
    @bookings = Booking
                .joins(:player)
                .includes(match: :team)
                .where(players: { team_id: params[:team_id] })
    render json: filter(@bookings)
  end

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
    @booking.destroy
    render json: @booking
  end

  private

    def set_match
      @match = Match.with_players.find(params[:match_id])
    end

    def booking_params
      params.require(:booking).permit Booking.permitted_attributes
    end
end
