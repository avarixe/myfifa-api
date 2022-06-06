# frozen_string_literal: true

module Mutations
  module LoanMutations
    class AddLoan < BaseAddMutation
      set_entity
      self.parent_type = 'Player'
    end

    class UpdateLoan < BaseUpdateMutation
      set_entity
    end

    class RemoveLoan < BaseRemoveMutation
      set_entity
    end
  end
end
