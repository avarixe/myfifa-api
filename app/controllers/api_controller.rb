class ApiController < ApplicationController
  before_action -> { doorkeeper_authorize! :api }
end
