# frozen_string_literal: true

module Mutations
  module CapMutations
    class AddCap < BaseAddMutation
      set_entity
      self.parent_type = 'Match'
    end

    class UpdateCap < BaseUpdateMutation
      set_entity

      def resolve(id:, attributes:)
        cap = Cap.find(id)

        if policy.new(current_user, cap).update?
          cap.attributes = attributes.to_h
          save_cap(cap)
          { cap: }
        else
          GraphQL::ExecutionError.new('You are not allowed to perform this action')
        end
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e.record.errors.full_messages.first)
      end

      def save_cap(cap)
        cap2 =
          if cap.pos_changed?
            other_cap(cap, 'pos')
          elsif cap.player_id_changed?
            other_cap(cap, 'player_id')
          end
        cap2.present? ? swap_pos(cap, cap2) : cap.save!
      end

      def swap_pos(cap, cap2)
        cap.restore_attributes
        values = [cap.pos, cap2.pos]
        Cap.transaction do
          cap2.pos = nil
          cap2.save(validate: false)
          cap.update!(pos: values[1])
          cap2.update!(pos: values[0])
        end
      end

      def other_cap(cap, attribute)
        cap.match.caps.find_by(start: cap.start, attribute => cap[attribute])
      end
    end

    class RemoveCap < BaseRemoveMutation
      set_entity
    end
  end
end
