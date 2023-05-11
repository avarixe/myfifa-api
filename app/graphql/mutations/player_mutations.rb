# frozen_string_literal: true

module Mutations
  module PlayerMutations
    class AddPlayer < BaseAddMutation
      set_entity
      self.parent_type = 'Team'
    end

    class UpdatePlayer < BaseUpdateMutation
      set_entity
    end

    class RemovePlayer < BaseRemoveMutation
      set_entity
    end

    class ReleasePlayer < BaseMutation
      description "Immediately expire Player's current Contract"

      argument :id, ID, 'ID of Player to terminate Contract', required: true

      field :player, Types::PlayerType,
            'Player who was released', null: false

      def resolve(id:)
        player = Player.find(id)
        if PlayerPolicy.new(context[:current_user], player).manage?
          player.current_contract&.terminate!
          { player: }
        else
          GraphQL::ExecutionError.new('You are not allowed to perform this action')
        end
      end
    end

    class RetirePlayer < BaseMutation
      description "Update Player's current Contract to expire " \
                  'at end of the current Season'

      argument :id, ID, 'ID of Player to retire', required: true

      field :player, Types::PlayerType,
            'Player that was marked as Retiring', null: false

      def resolve(id:)
        player = Player.find(id)
        if PlayerPolicy.new(context[:current_user], player).manage?
          player.current_contract&.retire!
          { player: }
        else
          GraphQL::ExecutionError.new('You are not allowed to perform this action')
        end
      end
    end
  end
end
