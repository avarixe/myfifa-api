# frozen_string_literal: true

module Mutations
  module ContractMutations
    class AddContract < BaseAddMutation
      set_entity
      self.parent_type = 'Player'
    end

    class UpdateContract < BaseUpdateMutation
      set_entity
    end

    class RemoveContract < BaseRemoveMutation
      set_entity
    end
  end
end
