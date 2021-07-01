# frozen_string_literal: true

module Types
  module Inputs
    class UserAttributes < BaseInputObject
      argument :full_name, String, required: false
      argument :email, String, required: false
      argument :username, String, required: false
    end
  end
end
