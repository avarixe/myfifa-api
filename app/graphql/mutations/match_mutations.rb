# frozen_string_literal: true

module Mutations
  module MatchMutations
    class AddMatch < BaseAddMutation
      set_entity
      self.parent_type = 'Team'
    end

    class UpdateMatch < BaseUpdateMutation
      set_entity
    end

    class RemoveMatch < BaseRemoveMutation
      set_entity
    end

    class ApplySquadToMatch < BaseMutation
      description 'load Match Caps with Squad Players and Positions'

      argument :match_id, ID, 'ID of Match to update', required: true
      argument :squad_id, ID, 'ID of Squad to be applied', required: true

      field :match, Types::MatchType,
            'Match that was updated based on Squad', null: false

      def resolve(match_id:, squad_id:)
        current_ability = Ability.new(context[:current_user])
        match = Match.accessible_by(current_ability).find(match_id)
        squad = Squad.accessible_by(current_ability).find(squad_id)
        match.apply squad
        { match: }
      end
    end
  end
end