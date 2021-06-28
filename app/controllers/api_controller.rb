# frozen_string_literal: true

class ApiController < ApplicationController
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

    def save_record(record)
      if record.invalid?
        render json: errors_json(record.errors.full_messages),
               status: :unprocessable_entity
      elsif record.save
        render json: record
      else
        render_server_error
      end
    end

    def errors_json(messages)
      { errors: Array(messages) }
    end

    def render_server_error
      render json: {
        errors: ['An error occurred while processing this request.']
      }, status: :interval_server_error
    end
end
