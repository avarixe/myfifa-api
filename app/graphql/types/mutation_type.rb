# frozen_string_literal: true

module Types
  class MutationType < BaseObject
    field :add_team, mutation: Mutations::AddTeam
    # field :update_team, mutation: Mutations::UpdateTeam

    %w[
      Booking
      Cap
      Competition
      Contract
      Fixture
      Goal
      Injury
      Loan
      Match
      PenaltyShootout
      Player
      Squad
      Stage
      Substitution
      TableRow
      Team
      Transfer
      User
    ].each do |klass|
      field "update_#{klass.underscore}".to_sym,
            mutation: Mutations::UpdateMutations.const_get("Update#{klass}")
      field "remove_#{klass.underscore}".to_sym,
            mutation: Mutations::RemoveMutations.const_get("Remove#{klass}")
    end
  end
end
