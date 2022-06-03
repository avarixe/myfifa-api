# frozen_string_literal: true

module Mutations
  module InjuryMutations
    class AddInjury < BaseAddMutation
      set_entity
      self.parent_type = 'Player'
    end

    class UpdateInjury < BaseUpdateMutation
      set_entity
    end

    class RemoveInjury < BaseRemoveMutation
      set_entity
    end
  end
end
