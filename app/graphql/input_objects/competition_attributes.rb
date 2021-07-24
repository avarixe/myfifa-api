# frozen_string_literal: true

module InputObjects
  class CompetitionAttributes < BaseTypes::BaseInputObject
    description 'Attributes to create/update a Competition record'

    argument :season, Integer,
             'Number of complete years between Team Start ' \
             'and this Competition',
             required: false
    argument :name, String, 'Name of this Competition', required: false
    argument :champion, String,
             'Name of Team that won this Competition', required: false

    argument :preset_format, String,
             'Type of Competition (League, Knockout, Group + Knockout)',
             required: false
    argument :num_teams, Integer,
             'Number of Teams in this Competition', required: false
    argument :num_teams_per_group, Integer,
             'Number of Teams per Group (League or Group + Knockout Only)',
             required: false
    argument :num_advances_from_group, Integer,
             "Number of Teams to Advance to Knockout Stages\n" \
             '(Group + Knockout Only)',
             required: false
  end
end
