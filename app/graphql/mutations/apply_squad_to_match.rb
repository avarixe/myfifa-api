# frozen_string_literal: true

module Mutations
  class ApplySquadToMatch < Mutations::BaseMutation
    argument :match_id, ID, required: true
    argument :squad_id, ID, required: true

    field :match, Types::Myfifa::MatchType, null: true

    def resolve(match_id:, squad_id:)
      match = Match.find(match_id)
      squad = Squad.find(squad_id)
      match.apply squad
      { match: match }
    end
  end
end
