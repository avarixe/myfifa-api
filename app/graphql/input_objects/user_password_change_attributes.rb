# frozen_string_literal: true

module InputObjects
  class UserPasswordChangeAttributes < BaseTypes::BaseInputObject
    description 'Attributes to change the password of a User record'

    argument :password, String,
             'New Password that will be used to authenticate this User',
             required: true
    argument :password_confirmation, String,
             'Confirmation of the new Password for this User',
             required: true
    argument :current_password, String,
             'Current Password to authenticate this request',
             required: true
  end
end
