# frozen_string_literal: true

module InputObjects
  class GoalAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Goal record'

    argument :minute, Integer, 'Minute of Match this occurred', required: true
    argument :player_name, String,
             'Name of Player who scored this Goal', required: false
    argument :player_id, ID,
             'ID of Player who scored this Goal if record exists',
             required: false
    argument :assisted_by, String,
             'Name of the Player who assisted the Goal', required: false
    argument :assist_id, ID,
             'ID of Player who assisted this Goal if record exists',
             required: false
    argument :home, Boolean,
             'Whether this Goal was scored by a Player on the Home Team',
             required: false
    argument :own_goal, Boolean,
             'Whether this Goal was an Own Goal', required: false
    argument :penalty, Boolean,
             'Whether this Goal was a Penalty', required: false
  end
end
