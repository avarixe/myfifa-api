# frozen_string_literal: true

module Types
  class MatchSetType < BaseTypes::BaseObject
    description 'Collection of filtered Matches'

    field :matches, [MatchType], 'Matches in this set', null: false
    field :total, Integer, 'Total number of Matches in this set', null: false
  end
end
