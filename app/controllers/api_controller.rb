class APIController < ApplicationController
  include CanCan::ControllerAdditions

  clear_respond_to
  respond_to :json

  # before_action :doorkeeper_authorize!
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |e|
    render json: errors_json(e.message), status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: errors_json(e.message), status: :not_found
  end

  private

    def authenticate_user!
      if doorkeeper_token
        user = User.find(doorkeeper_token.resource_owner_id)
        Thread.current[:current_user] = user
      end

      return if current_user

      render json: { errors: ['User is not authenticated!'] },
             status: :unauthorized
    end

    def current_user
      Thread.current[:current_user]
    end

    def errors_json(messages)
      { errors: [*messages] }
    end

    def render_server_error
      render json: {
        errors: [
          'An error occurred while processing this request.'
        ]
      }, status: 500
    end

    def save_record(record, options = {})
      if record.invalid?
        render json: { errors: record.errors.full_messages },
               status: 422
      elsif record.save
        puts options[:json].to_json
        puts record.to_json
        render json: options[:json] || record
      else
        render_server_error
      end
    end
end
