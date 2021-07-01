# frozen_string_literal: true

module Types
  module Myfifa
    class UserType < BaseObject
      field :id, ID, null: false
      field :full_name, String, null: false
      field :username, String, null: false
      field :email, String, null: false

      field :teams, [TeamType], null: false
    end
  end
end
