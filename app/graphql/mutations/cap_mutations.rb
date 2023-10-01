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

    class SubstituteCap < BaseMutation
      description 'Create Substitute Cap with the provided attributes'

      argument :id, GraphQL::Types::ID,
               'ID of Cap to substitute', required: true
      argument :attributes, InputObjects::CapSubstitutionAttributes,
               'Data object to substitute Cap', required: true

      field :cap, Types::CapType, 'Cap that was substituted', null: false
      field :replacement, Types::CapType,
            'Replacement Cap that was created', null: false

      def resolve(id:, attributes:)
        cap = Cap.find(id)

        if CapPolicy.new(context[:current_user], cap).substitute?
          substitute_cap(cap, attributes)
          { cap:, replacement: @replacement }
        else
          GraphQL::ExecutionError.new('You are not allowed to perform this action')
        end
      rescue ActiveRecord::RecordInvalid => e
        GraphQL::ExecutionError.new(e.record.errors.full_messages.first)
      end

      def substitute_cap(cap, attributes)
        cap.injured = attributes[:injured]
        @replacement = cap.build_next(
          match_id: cap.match_id,
          player_id: attributes[:player_id],
          start: attributes[:minute],
          pos: attributes[:pos]
        )
        Cap.transaction do
          cap.save! && @replacement.save!
        end
      end
    end

    class RemoveCap < BaseRemoveMutation
      set_entity
    end
  end
end
