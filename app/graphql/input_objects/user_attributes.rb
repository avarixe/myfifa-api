# frozen_string_literal: true

module InputObjects
  class UserAttributes < BaseTypes::BaseInputObject
    description 'Attributes to update a User record'

    argument :username, String,
             'Unique Username of this User', required: false
    argument :email, String,
             'Unique Email Address of this User', required: false
    argument :full_name, String, 'Name of this User', required: false
    argument :dark_mode, Boolean,
             'Whether Dark Mode is enabled for this User', required: false
  end
end
