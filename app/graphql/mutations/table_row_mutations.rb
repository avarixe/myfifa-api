# frozen_string_literal: true

module Mutations
  module TableRowMutations
    class AddTableRow < BaseAddMutation
      set_entity
      self.parent_type = 'Stage'
    end

    class UpdateTableRow < BaseUpdateMutation
      set_entity
    end

    class RemoveTableRow < BaseRemoveMutation
      set_entity
    end
  end
end
