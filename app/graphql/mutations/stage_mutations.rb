# frozen_string_literal: true

module Mutations
  module StageMutations
    class AddStage < BaseAddMutation
      set_entity
      self.parent_type = 'Competition'
    end

    class UpdateStage < BaseUpdateMutation
      set_entity
    end

    class RemoveStage < BaseRemoveMutation
      set_entity
    end
  end
end
