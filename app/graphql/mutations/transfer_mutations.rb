# frozen_string_literal: true

module Mutations
  module TransferMutations
    class AddTransfer < BaseAddMutation
      set_entity
      self.parent_type = 'Player'
    end

    class UpdateTransfer < BaseUpdateMutation
      set_entity
    end

    class RemoveTransfer < BaseRemoveMutation
      set_entity
    end
  end
end
