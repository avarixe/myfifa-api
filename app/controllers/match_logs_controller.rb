class MatchLogsController < APIController
  load_and_authorize_resource :match
  load_and_authorize_resource through: :match, shallow: true

  def create
    save_record @match_log, json: @match
  end

  def update
    @match_log.attributes = match_log_params
    save_record @match_log, json: @match_log.match
  end

  private

    def match_log_params
      params.require(:match_log).permit(MatchLog.permitted_attributes)
    end
end