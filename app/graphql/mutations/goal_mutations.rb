# frozen_string_literal: true

module Mutations
  module GoalMutations
    class AddGoal < BaseAddMutation
      set_entity
      self.parent_type = 'Match'
    end

    class UpdateGoal < BaseUpdateMutation
      set_entity
    end

    class RemoveGoal < BaseRemoveMutation
      set_entity
    end
  end
end
