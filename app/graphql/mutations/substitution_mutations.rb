# frozen_string_literal: true

module Mutations
  module SubstitutionMutations
    class AddSubstitution < BaseAddMutation
      set_entity
      self.parent_type = 'Match'
    end

    class UpdateSubstitution < BaseUpdateMutation
      set_entity
    end

    class RemoveSubstitution < BaseRemoveMutation
      set_entity
    end
  end
end
