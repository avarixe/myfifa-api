# frozen_string_literal: true

class GraphqlController < ApplicationController
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
      # Query context goes here, for example:
      current_user: current_user,
      pundit: self
    }
    result = MyfifaApiSchema.execute query,
                                     variables: variables,
                                     context: context,
                                     operation_name: operation_name
    render json: result
  end

  public :policy_scope

  private

    # Handle variables in form data, JSON body, or a blank value
    def prepare_variables(variables_param)
      case variables_param.presence
      when String
        JSON.parse(variables_param) || {}
      when ActionController::Parameters
        # GraphQL-Ruby will validate name and type of incoming variables.
        variables_param.to_unsafe_hash
      else
        {}
      end
    end
end
