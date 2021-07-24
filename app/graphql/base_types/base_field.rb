# frozen_string_literal: true

module BaseTypes
  class BaseField < GraphQL::Schema::Field
    argument_class BaseArgument
  end
end
