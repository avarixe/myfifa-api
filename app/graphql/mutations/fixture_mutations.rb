# frozen_string_literal: true

module Mutations
  module FixtureMutations
    class AddFixture < BaseAddMutation
      set_entity
      self.parent_type = 'Stage'
    end

    class UpdateFixture < BaseUpdateMutation
      set_entity
    end

    class RemoveFixture < BaseRemoveMutation
      set_entity
    end
  end
end
