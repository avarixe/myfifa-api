# frozen_string_literal: true

module Types
  class GoalType < BaseTypes::BaseObject
    description 'Record of a Player scoring a point in a Match'

    field :id, ID, 'Unique Identifer of record', null: false
    field :match_id, ID, 'ID of Match', null: false
    field :minute, Integer, 'Minute of Match this occurred', null: false
    field :player_name, String,
          'Name of Player who scored this Goal', null: false
    field :cap_id, ID,
          'ID of Player Cap who scored this Goal if record exists', null: true
    field :player_id, ID,
          'ID of Player who scored this Goal if record exists', null: true
    field :assisted_by, String,
          'Name of the Player who assisted the Goal', null: true
    field :assist_cap_id, ID,
          'ID of Player Cap who assisted this Goal if record exists', null: true
    field :assist_id, ID,
          'ID of Player who assisted this Goal if record exists', null: true
    field :home, Boolean,
          'Whether this Goal was scored by a Player on the Home Team',
          null: false
    field :own_goal, Boolean, 'Whether this Goal was an Own Goal', null: false
    field :penalty, Boolean, 'Whether this Goal was a Penalty', null: false
    field :created_at, GraphQL::Types::ISO8601DateTime,
          'Timestamp this record was created', null: false

    field :player, PlayerType, 'Player who scored this Goal', null: true
    field :assisting_player, PlayerType,
          'Player who assisted this Goal', null: true
  end
end
