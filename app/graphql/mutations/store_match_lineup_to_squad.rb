# frozen_string_literal: true

module Mutations
  class StoreMatchLineupToSquad < Mutations::BaseMutation
    argument :match_id, ID, required: true
    argument :squad_id, ID, required: true

    field :squad, Types::Myfifa::MatchType, null: true

    def resolve(match_id:, squad_id:)
      match = Match.find(match_id)
      squad = Squad.find(squad_id)
      squad.store_lineup match
      { squad: squad }
    end
  end
end
