# frozen_string_literal: true

module Mutations
  module CompetitionMutations
    class AddCompetition < BaseAddMutation
      set_entity
      self.parent_type = 'Team'
    end

    class UpdateCompetition < BaseUpdateMutation
      set_entity
    end

    class RemoveCompetition < BaseRemoveMutation
      set_entity
    end
  end
end
