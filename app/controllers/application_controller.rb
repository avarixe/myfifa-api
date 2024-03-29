# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include Pundit::Authorization

  private

    def current_user
      @current_user ||= authenticate_with_http_token do |token|
        AccessToken.active.find_by(token:)&.user
      end
    end
end
