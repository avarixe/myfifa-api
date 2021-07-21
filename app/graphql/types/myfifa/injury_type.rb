# frozen_string_literal: true

module Types
  module Myfifa
    class InjuryType < BaseObject
      description 'Record of a Player being unavailable due to physical injury'

      field :id, ID, 'Unique Identifer of record', null: false
      field :player_id, ID, 'ID of Player', null: false
      field :started_on, GraphQL::Types::ISO8601Date,
            'Date Player was afflicted by this Injury', null: false
      field :ended_on, GraphQL::Types::ISO8601Date,
            'Date Player recovered from this Injury', null: true
      field :description, String, 'Description of this Injury', null: false
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false

      field :player, PlayerType, 'Injured Player', null: false
    end
  end
end
