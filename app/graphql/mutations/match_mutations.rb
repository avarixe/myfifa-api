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
        match = MatchPolicy::Scope.new(context[:current_user], Match).resolve.find(match_id)
        squad = SquadPolicy::Scope.new(context[:current_user], Squad).resolve.find(squad_id)
        match.apply squad
        { match: }
      end
    end

    class UpdateMatchFormation < BaseMutation
      description 'update Caps with new formation'

      argument :id, ID, 'ID of Match to update', required: true
      argument :minute, Integer, 'Minute to apply formation changes', required: true
      argument :formation, [InputObjects::SquadPlayerAttributes],
               'New Formation as Position/Player pairs', required: true

      field :match, Types::MatchType,
            'Match that was updated based on Formation', null: false

      def resolve(id:, minute:, formation:)
        match = MatchPolicy::Scope.new(context[:current_user], Match).resolve.find(id)

        Cap.transaction do
          formation.each do |cell|
            cap = match.caps.find_by start: ..minute,
                                     stop: minute..,
                                     next_id: nil,
                                     id: cell[:id]
            update_cap!(cap:, cell:, minute:) if cap.present?
          end
        end

        { match: }
      end

      def update_cap!(cap:, cell:, minute:)
        return if cap.player_id == cell[:player_id].to_i && cap.pos == cell[:pos]

        cap.create_next!(
          match_id: cap.match_id,
          player_id: cell[:player_id],
          pos: cell[:pos],
          start: minute
        )
      end
    end
  end
end
