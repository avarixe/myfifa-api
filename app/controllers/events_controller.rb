class EventsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource :event, through: :match, shallow: true
  before_action :set_type

  def index
    render json: @events
  end

  def show
    @event = @event.becomes(@type)
    render json: @event
  end

  def create
    @event = @match.events.new(event_params)
    save_record @event
  end

  def update
    @event.attributes = event_params
    save_record @event
  end

  def destroy
    render json: @event.destroy
  end

  private

    def event_params
      params.require(:event).permit(@type.permitted_attributes)
    end

    def set_type
      @type = Event.const_get(params[:type].singularize.titleize.tr(' ', ''))
    end
end
