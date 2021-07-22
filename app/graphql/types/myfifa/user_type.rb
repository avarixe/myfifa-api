# frozen_string_literal: true

module Types
  module Myfifa
    class UserType < BaseObject
      description 'Record of a User of the API'

      field :id, ID, 'Unique Identifer of record', null: false
      field :email, String, 'Unique Email Address of this User', null: false
      field :username, String, 'Unique Username of this User', null: false
      field :full_name, String, 'Name of this User', null: false
      field :dark_mode, Boolean,
            'Whether Dark Mode is enabled for this User', null: false
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false

      field :teams, [TeamType], 'List of Teams bound to this User', null: false
    end
  end
end
