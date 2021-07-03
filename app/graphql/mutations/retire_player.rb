# frozen_string_literal: true

module Mutations
  class RetirePlayer < Mutations::BaseMutation
    argument :id, ID, required: true

    field :player, Types::Myfifa::PlayerType, null: true

    def resolve(id:)
      player = Player.find(id)
      player.current_contract&.retire!
      { player: player }
    end
  end
end
