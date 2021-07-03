# frozen_string_literal: true

module Mutations
  class ReleasePlayer < Mutations::BaseMutation
    argument :id, ID, required: true

    field :player, Types::Myfifa::PlayerType, null: true

    def resolve(id:)
      player = Player.find(id)
      player.current_contract&.terminate!
      { player: player }
    end
  end
end
