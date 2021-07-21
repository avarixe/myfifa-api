# frozen_string_literal: true

module Types
  module Inputs
    class StageAttributes < BaseInputObject
      description 'Attributes to create/update a Stage record'

      argument :name, String, 'Name of this Stage', required: false
      argument :num_teams, Integer,
               'Number of Teams participating in this Stage', required: false
      argument :num_fixtures, Integer,
               'Number of Fixtures in this Stage', required: false
      argument :table, Boolean, 'Whether this Stage is a Table', required: false
    end
  end
end
