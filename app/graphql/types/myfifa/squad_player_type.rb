# frozen_string_literal: true

module Types
  module Myfifa
    class SquadPlayerType < Types::BaseObject
      field :id, ID, null: false
      field :squad_id, Integer, null: false
      field :player_id, Integer, null: false
      field :pos, String, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :squad, SquadType, null: false
      field :player, PlayerType, null: false
    end
  end
end
