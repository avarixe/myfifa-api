# frozen_string_literal: true

module BaseTypes
  class BaseInputObject < GraphQL::Schema::InputObject
    argument_class BaseArgument
  end
end
