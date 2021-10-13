# frozen_string_literal: true

module Enums
  class OptionCategoryEnum < BaseTypes::BaseEnum
    graphql_name 'OptionCategory'
    description 'Subset of Options entered by User'

    value 'Competition', 'Name of a Football League/Cup'
    value 'Team', 'Name of a Football Team/Club'
  end
end
