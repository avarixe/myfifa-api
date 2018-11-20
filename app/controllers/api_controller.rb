# frozen_string_literal: true

class APIController < ApplicationController
  include CanCan::ControllerAdditions
  include Authentication

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

    def errors_json(messages)
      { errors: [*messages] }
    end

    def render_server_error
      render json: {
        errors: ['An error occurred while processing this request.']
      }, status: :interval_server_error
    end

    def save_record(record, options = {})
      if record.invalid?
        render json: { errors: record.errors.full_messages },
               status: :unprocessable_entity
      elsif record.save
        options[:json] = options[:json].call if options[:json].class == Proc
        render json: options[:json] || record
      else
        render_server_error
      end
    end
end
