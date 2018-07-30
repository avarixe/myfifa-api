class MatchLogsController < APIController
  load_and_authorize_resource :match
  load_resource through: :match, shallow: true
  # load_and_authorize_resource through: :match, shallow: true

  def index
    @match_logs = @match_logs.includes(:player)
    render json: @match_logs
  end

  def create
    save_record @match_log
  end

  def update
    @match_log.attributes = match_log_params
    save_record @match_log
  end

  private

    def match_log_params
      params.require(:match_log).permit(MatchLog.permitted_attributes)
    end
end