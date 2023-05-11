# frozen_string_literal: true

module Mutations
  module SquadMutations
    class AddSquad < BaseAddMutation
      set_entity
      self.parent_type = 'Team'
    end

    class UpdateSquad < BaseUpdateMutation
      set_entity
    end

    class RemoveSquad < BaseRemoveMutation
      set_entity
    end

    class StoreMatchLineupToSquad < BaseMutation
      description 'Overwrite existing Squad ' \
                  'with Starting Players and Positions of a Match'

      argument :match_id, ID, 'ID of Match to store Lineup from', required: true
      argument :squad_id, ID, 'ID of Squad to update', required: true

      field :squad, Types::SquadType,
            'Squad that was updated based on Match', null: false

      def resolve(match_id:, squad_id:)
        match = MatchPolicy::Scope.new(context[:current_user], Match).resolve.find(match_id)
        squad = SquadPolicy::Scope.new(context[:current_user], Squad).resolve.find(squad_id)
        squad.store_lineup match
        { squad: }
      end
    end
  end
end
