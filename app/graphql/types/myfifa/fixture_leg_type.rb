# frozen_string_literal: true

module Types
  module Myfifa
    class FixtureLegType < BaseObject
      description 'Record of a Leg of a Competition Fixture'

      field :id, ID, 'Unique Identifer of record', null: false
      field :fixture_id, ID, 'ID of Fixture', null: false
      field :home_score, String, 'Score of the Home Team', null: true
      field :away_score, String, 'Score of the Away Team', null: true
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false

      field :fixture, FixtureType,
            'Fixture pertaining to this Leg', null: false
    end
  end
end
