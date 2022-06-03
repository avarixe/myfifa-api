# frozen_string_literal: true

module Mutations
  module CapMutations
    class AddCap < BaseAddMutation
      set_entity
      self.parent_type = 'Match'
    end

    class UpdateCap < BaseUpdateMutation
      set_entity
    end

    class RemoveCap < BaseRemoveMutation
      set_entity
    end
  end
end
