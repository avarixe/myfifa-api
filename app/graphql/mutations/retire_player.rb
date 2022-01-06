# frozen_string_literal: true

module Mutations
  class RetirePlayer < Mutations::BaseMutation
    description "Update Player's current Contract to expire " \
                'at end of the current Season'

    argument :id, ID, 'ID of Player to retire', required: true

    field :player, Types::PlayerType,
          'Player that was marked as Retiring', null: false

    def resolve(id:)
      player = context[:pundit].policy_scope(Player).find(id)
      player.current_contract&.retire!
      { player: player }
    end
  end
end
