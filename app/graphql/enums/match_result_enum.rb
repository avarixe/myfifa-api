# frozen_string_literal: true

module Enums
  class MatchResultEnum < BaseTypes::BaseEnum
    graphql_name 'MatchResult'
    description 'Result of Match relative to tracked Team'

    value 'win', 'Win'
    value 'draw', 'Draw'
    value 'loss', 'Loss'
  end
end
