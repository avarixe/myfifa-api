# frozen_string_literal: true

module Types
  module Inputs
    class SquadAttributes < BaseInputObject
      description 'Attributes to create/update a Squad record'

      argument :name, String, 'Name of this Squad', required: true

      argument :squad_players_attributes, [SquadPlayerAttributes],
               'List of attributes for player slots bound to this Squad',
               required: true
    end
  end
end
