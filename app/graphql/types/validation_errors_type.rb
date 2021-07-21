# frozen_string_literal: true

module Types
  class ValidationErrorsType < Types::BaseObject
    description 'Errors from a record failing validation'

    field :details, String, 'Error Details', null: false
    field :full_messages, [String],
          'List of Human-Friendly Error Messages', null: false

    def details
      object.details.to_json
    end
  end
end
