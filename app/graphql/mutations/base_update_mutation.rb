# frozen_string_literal: true

module Mutations
  class BaseUpdateMutation < BaseMutation
    class_attribute :record_field_name,
                    :entity_klass_name,
                    :entity_type,
                    :entity_attributes,
                    :model_klass,
                    :policy

    def self.set_entity
      self.entity_klass_name = to_s.demodulize.gsub('Update', '')
      self.record_field_name = entity_klass_name.to_s.underscore.to_sym
      self.entity_type = Types.const_get("#{entity_klass_name}Type")
      self.entity_attributes = InputObjects.const_get("#{entity_klass_name}Attributes")
      self.model_klass = entity_klass_name.constantize
      self.policy ||= "#{entity_klass_name}Policy".constantize

      description "Update #{entity_klass_name} with the provided attributes"

      argument :id, GraphQL::Types::ID,
               "ID of #{entity_klass_name} to update", required: true
      argument :attributes, entity_attributes,
               "Data object to update #{entity_klass_name}", required: true

      field record_field_name, entity_type,
            "#{entity_klass_name} that was updated if attributes were saved",
            null: false
    end

    def current_user
      @current_user ||= context[:current_user]
    end

    def resolve(id:, attributes:)
      record = self.class.model_klass.find(id)

      if policy.new(current_user, record).update?
        record.skip_preload.update!(attributes.to_h)
        { self.class.record_field_name => record }
      else
        GraphQL::ExecutionError.new('You are not allowed to perform this action')
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new(e.record.errors.full_messages.first)
    end
  end
end
