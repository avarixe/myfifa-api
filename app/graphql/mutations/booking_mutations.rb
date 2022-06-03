# frozen_string_literal: true

module Mutations
  module BookingMutations
    class AddBooking < BaseAddMutation
      set_entity
      self.parent_type = 'Match'
    end

    class UpdateBooking < BaseUpdateMutation
      set_entity
    end

    class RemoveBooking < BaseRemoveMutation
      set_entity
    end
  end
end
