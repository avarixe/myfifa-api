# frozen_string_literal: true

module Types
  module Myfifa
    class MatchType < BaseObject
      description 'Record of a Soccer/Football Game'

      field :id, ID, 'Unique Identifer of record', null: false
      field :team_id, ID, 'ID of Team', null: false
      field :home, String, 'Name of Home Team', null: false
      field :away, String, 'Name of Away Team', null: false
      field :competition, String, 'Name of Competition', null: true
      field :season, Integer,
            'Number of complete years between Team Start and this Match',
            null: false
      field :played_on, GraphQL::Types::ISO8601Date,
            'Date this Match was played', null: false
      field :created_at, GraphQL::Types::ISO8601DateTime,
            'Timestamp this record was created', null: false
      field :extra_time, Boolean,
            'Whether this Match required an Extra 30 Minutes', null: false
      field :home_score, Integer, 'Points scored for Home Team', null: false
      field :away_score, Integer, 'Points scored for Away Team', null: false
      field :stage, String, 'Name of Competition Stage', null: true
      field :friendly, Boolean,
            'Whether this record was non-Competitive', null: false

      field :score, String, 'Score Display of both Teams', null: false
      field :team_result, String,
            'Result of the Match in terms of bound Team, if applicable',
            null: false

      field :team, TeamType, 'Team pertaining to this Match', null: false
      field :caps, [CapType], 'List of Caps bound to this Match', null: false
      field :goals, [GoalType],
            'List of Goals scored in this Match', null: false
      field :substitutions, [SubstitutionType],
            'List of Substitutions made in this Match', null: false
      field :bookings, [BookingType],
            'List of Bookings made in this Match', null: false
      field :penalty_shootout, PenaltyShootoutType,
            'Penalty Shootout bound to this Match', null: true
    end
  end
end
