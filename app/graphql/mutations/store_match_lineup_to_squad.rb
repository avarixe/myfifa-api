# frozen_string_literal: true

module Mutations
  class StoreMatchLineupToSquad < Mutations::BaseMutation
    description 'Overwrite existing Squad ' \
                'with Starting Players and Positions of a Match'

    argument :match_id, ID, 'ID of Match to store Lineup from', required: true
    argument :squad_id, ID, 'ID of Squad to update', required: true

    field :squad, Types::SquadType,
          'Squad that was updated based on Match', null: false

    def resolve(match_id:, squad_id:)
      current_ability = Ability.new(context[:current_user])
      match = Match.accessible_by(current_ability).find(match_id)
      squad = Squad.accessible_by(current_ability).find(squad_id)
      squad.store_lineup match
      { squad: }
    end
  end
end
