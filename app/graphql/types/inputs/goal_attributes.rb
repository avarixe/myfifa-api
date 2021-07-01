# frozen_string_literal: true

module Types
  module Inputs
    class GoalAttributes < BaseInputObject
      argument :minute, Integer, required: true
      argument :player_name, String, required: false
      argument :player_id, Integer, required: false
      argument :assist_id, Integer, required: false
      argument :home, Boolean, required: true
      argument :own_goal, Boolean, required: true
      argument :penalty, Boolean, required: true
      argument :assisted_by, String, required: false
    end
  end
end
