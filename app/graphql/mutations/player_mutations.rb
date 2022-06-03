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
        current_ability = Ability.new(context[:current_user])
        player = Player.accessible_by(current_ability).find(id)
        player.current_contract&.terminate!
        { player: }
      end
    end

    class RetirePlayer < BaseMutation
      description "Update Player's current Contract to expire " \
                  'at end of the current Season'

      argument :id, ID, 'ID of Player to retire', required: true

      field :player, Types::PlayerType,
            'Player that was marked as Retiring', null: false

      def resolve(id:)
        current_ability = Ability.new(context[:current_user])
        player = Player.accessible_by(current_ability).find(id)
        player.current_contract&.retire!
        { player: }
      end
    end
  end
end
