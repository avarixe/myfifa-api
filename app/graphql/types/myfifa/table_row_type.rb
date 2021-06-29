# frozen_string_literal: true

module Types
  module Myfifa
    class TableRowType < Types::BaseObject
      field :id, ID, null: false
      field :stage_id, Integer, null: false
      field :name, String, null: true
      field :wins, Integer, null: true
      field :draws, Integer, null: true
      field :losses, Integer, null: true
      field :goals_for, Integer, null: true
      field :goals_against, Integer, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :stage, StageType, null: false
    end
  end
end
