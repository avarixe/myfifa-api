# frozen_string_literal: true

module Types
  module Inputs
    class UserRegistrationAttributes < BaseInputObject
      description 'Attributes to create a User record'

      argument :username, String,
               'Unique Username of this User', required: true
      argument :email, String,
               'Unique Email Address of this User', required: true
      argument :full_name, String, 'Name of this User', required: true
      argument :password, String,
               'Password that will be used to authenticate this User',
               required: true
      argument :password_confirmation, String,
               'Confirmation of the designated Password for this User',
               required: true
    end
  end
end
