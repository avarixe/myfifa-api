# frozen_string_literal: true

module Mutations
  class ReleasePlayer < Mutations::BaseMutation
    description "Immediately expire Player's current Contract"

    argument :id, ID, 'ID of Player to terminate Contract', required: true

    field :player,
          Types::Myfifa::PlayerType,
          'Player who was released',
          null: false

    def resolve(id:)
      current_ability = Ability.new(context[:current_user])
      player = Player.accessible_by(current_ability).find(id)
      player.current_contract&.terminate!
      { player: player }
    end
  end
end
