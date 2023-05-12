# frozen_string_literal: true

module Types
  class CapSetType < BaseTypes::BaseObject
    description 'Collection of filtered Caps'

    field :caps, [CapType], 'Caps in this set', null: false
    field :total, Integer, 'Total number of Cap in this set', null: false
  end
end
