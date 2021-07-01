# frozen_string_literal: true

module Types
  module Inputs
    class CompetitionAttributes < BaseInputObject
      argument :season, Integer, required: false
      argument :name, String, required: false
      argument :champion, String, required: false
    end
  end
end
